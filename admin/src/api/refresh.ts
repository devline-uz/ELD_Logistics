/**
 * Access token yangilash: **mutex + proaktiv (80% TTL) + reaktiv (401)**
 * (0.13, fe-api §4).
 *
 * ## Nima uchun alohida klient
 * `POST /auth/refresh` **middleware'siz** klient orqali yuboriladi. Sabab:
 * - `authMiddleware` kerak emas (endpoint public, refresh token tanada);
 * - `errorMiddleware` `ApiError` otishi kerak emas — natija shu yerda hal qilinadi;
 * - `refreshMiddleware` refresh so'rovining o'ziga **hech qachon** ilinmasligi
 *   kerak, aks holda 401 → refresh → 401 → … cheksiz halqa hosil bo'ladi.
 *
 * ## Mutex
 * Bir vaqtda nechta so'rov 401 olsa ham `refreshTokens()` **bitta** tarmoq
 * chaqiruvi qiladi: birinchi chaqiruv `inFlight` promise'ni yaratadi, qolganlari
 * o'shani kutadi. Promise yakunlangach `inFlight` bo'shatiladi.
 *
 * ## Reuse detection
 * Backend eski refresh token ishlatilganini aniqlasa butun sessiya oilasini
 * bekor qiladi va `401 REFRESH_REUSED` (yoki oddiy 401/403) qaytaradi. Bunda
 * frontend **to'liq logout** qiladi: xotira + `sessionStorage` tozalanadi,
 * tinglovchilar (`queryClient.clear()`, WS yopilishi, `/login` ga redirect)
 * xabardor qilinadi. Hech qanday "silent retry" yo'q.
 */
import createClient from 'openapi-fetch';

import { authState } from '@/store/auth-store';
import { companyState } from '@/store/company-store';

import { readRefreshToken, writeRefreshToken } from './refresh-token';
import { endSession, onSessionEnded } from './session';
import type { paths } from './schema';
import type { Tokens } from './types';

/** Proaktiv yangilash access token TTL ning shu ulushida bajariladi. */
export const PROACTIVE_REFRESH_RATIO = 0.8;

/** TTL noma'lum bo'lsa ishlatiladigan zaxira qiymat (sekund). */
const FALLBACK_TTL_SECONDS = 900;

/** Taymer `setTimeout` chegarasidan oshmasligi uchun yuqori chek (~24 kun). */
const MAX_TIMEOUT_MS = 2_147_483_647;

/** Refresh so'rovi middleware'lardan o'tmaydi — §«Nima uchun alohida klient». */
const refreshClient = createClient<paths>({
  baseUrl: import.meta.env.VITE_API_BASE_URL,
  headers: { Accept: 'application/json' },
});

export type RefreshFailureReason =
  /** `sessionStorage` da refresh token yo'q — sessiya umuman mavjud emas. */
  | 'no_token'
  /** 401/403 — token bekor qilingan yoki qayta ishlatilgan → to'liq logout. */
  | 'revoked'
  /** Tarmoq/5xx/429 — sessiya saqlanadi, so'rov shunchaki muvaffaqiyatsiz. */
  | 'transient';

export type RefreshOutcome =
  { ok: true; accessToken: string } | { ok: false; reason: RefreshFailureReason };

/* ------------------------------------------------------------------ *
 * Proaktiv taymer
 * ------------------------------------------------------------------ */

let proactiveTimer: ReturnType<typeof setTimeout> | null = null;

function cancelProactiveRefresh(): void {
  if (proactiveTimer !== null) {
    clearTimeout(proactiveTimer);
    proactiveTimer = null;
  }
}

// Sessiya tugaganda taymer ham to'xtaydi — aks holda logoutdan keyin ham
// refresh urinishi ketaveradi.
onSessionEnded(cancelProactiveRefresh);

function scheduleProactiveRefresh(ttlSeconds: number): void {
  cancelProactiveRefresh();

  const delayMs = Math.min(
    MAX_TIMEOUT_MS,
    Math.max(0, Math.round(ttlSeconds * PROACTIVE_REFRESH_RATIO * 1000)),
  );

  proactiveTimer = setTimeout(() => {
    proactiveTimer = null;
    void refreshTokens();
  }, delayMs);

  // Node/Vitest muhitida ochiq taymer jarayonni ushlab qolmasin.
  (proactiveTimer as { unref?: () => void }).unref?.();
}

/* ------------------------------------------------------------------ *
 * Tokenlarni qo'llash
 * ------------------------------------------------------------------ */

/**
 * `LoginResult` / `Tokens` javobini sessiyaga yozadi va proaktiv taymerni
 * qayta rejalashtiradi. Login, 2FA verify va refresh — uchalasi shu funksiya
 * orqali o'tadi, shunda saqlash qoidasi bitta joyda qoladi.
 */
export function applyTokens(
  tokens: Tokens,
  options: {
    sessionId?: string | null;
    limited?: boolean;
    /** `POST /auth/login` javobidagi sessiya bayroqlari — faqat login chaqiradi. */
    subscriptionReadonly?: boolean;
    replacedSession?: boolean;
  } = {},
): void {
  const accessToken = tokens.access_token ?? '';
  if (accessToken === '') return;

  const ttlSeconds =
    tokens.expires_in && tokens.expires_in > 0
      ? tokens.expires_in
      : companyState().appConfig.accessTokenTtlSeconds || FALLBACK_TTL_SECONDS;

  authState().setTokens({
    accessToken,
    expiresInSeconds: ttlSeconds,
    sessionId: options.sessionId ?? null,
    limited: options.limited ?? false,
    subscriptionReadonly: options.subscriptionReadonly,
    replacedSession: options.replacedSession,
  });

  // Cheklangan (2FA enrolment) sessiyada refresh token bo'sh keladi — uni
  // saqlamaymiz va proaktiv refresh ham rejalashtirilmaydi.
  const refreshToken = tokens.refresh_token ?? '';
  if (refreshToken !== '') {
    writeRefreshToken(refreshToken);
    scheduleProactiveRefresh(ttlSeconds);
  }
}

/* ------------------------------------------------------------------ *
 * Mutex
 * ------------------------------------------------------------------ */

let inFlight: Promise<RefreshOutcome> | null = null;

/** Test uchun: modul holatini boshlang'ich ko'rinishga qaytaradi. */
export function resetRefreshState(): void {
  cancelProactiveRefresh();
  inFlight = null;
}

async function runRefresh(): Promise<RefreshOutcome> {
  const refreshToken = readRefreshToken();
  if (refreshToken === null) {
    endSession('session_expired');
    return { ok: false, reason: 'no_token' };
  }

  let response: Response;
  let data: { data?: Tokens } | undefined;

  try {
    const result = await refreshClient.POST('/auth/refresh', {
      body: { refresh_token: refreshToken },
    });
    response = result.response;
    data = result.data;
  } catch {
    // Tarmoq xatosi — sessiya bekor qilinmaydi, so'rov qayta urinilmaydi.
    return { ok: false, reason: 'transient' };
  }

  if (response.status === 401 || response.status === 403) {
    // Reuse detection yoki bekor qilingan sessiya → to'liq logout.
    endSession('session_expired');
    return { ok: false, reason: 'revoked' };
  }

  const tokens = data?.data;
  if (!response.ok || !tokens?.access_token) {
    return { ok: false, reason: 'transient' };
  }

  applyTokens(tokens, { sessionId: authState().sessionId, limited: false });
  return { ok: true, accessToken: tokens.access_token };
}

/**
 * Access tokenni yangilaydi. Bir vaqtda chaqirilgan barcha kutuvchilar
 * **bitta** `POST /auth/refresh` natijasini oladi (mutex).
 */
export function refreshTokens(): Promise<RefreshOutcome> {
  inFlight ??= runRefresh().finally(() => {
    inFlight = null;
  });
  return inFlight;
}

/** Hozir refresh so'rovi ketayotganmi (test va diagnostika uchun). */
export function isRefreshing(): boolean {
  return inFlight !== null;
}
