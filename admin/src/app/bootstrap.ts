/**
 * Ilova bootstrap'i (0.14 + 0.15).
 *
 * Ilova render qilinishidan **oldin bir marta** bajariladi:
 *
 * 1. `GET /app/config` (public) — server vaqti bo'yicha soat siljishi,
 *    feature flag'lar, access token TTL. Bu qadam **majburiy**: yiqilsa
 *    to'liq ekranli xato + «Try again» ko'rsatiladi (fe-screens §7.1).
 * 2. Sessiyani tiklash — `sessionStorage` da refresh token bo'lsa
 *    `POST /auth/refresh` (sahifa yangilanganda access token xotiradan
 *    yo'qolgan bo'ladi, bu kutilgan xatti-harakat).
 * 3. `GET /me` — profil va ruxsat ro'yxati. `401` bo'lsa bu xato emas:
 *    foydalanuvchi shunchaki tizimga kirmagan.
 * 4. `GET /company` — kompaniya konteksti (`region`, `unit_system`,
 *    `regulation_profile`, `timezone`). Faqat `company.read` ruxsati bo'lsa
 *    so'raladi; yiqilsa bootstrap yiqilmaydi (default kontekst qoladi).
 */
import { fetchAppConfig, fetchCompany, fetchProfile } from '@/api/auth.api';
import { refreshTokens } from '@/api/refresh';
import { endSession, hasStoredRefreshToken } from '@/api/session';
import { purgeLegacyTokenStorage } from '@/api/refresh-token';
import type { AppConfig, Company } from '@/api/types';
import { isApiError } from '@/lib/errors';
import { PERM } from '@/lib/permissions';
import { authState } from '@/store/auth-store';
import { companyState, DEFAULT_COMPANY_CONTEXT } from '@/store/company-store';

/** `server_time` (RFC3339) → klient soati bilan farq (ms). */
export function computeClockSkewMs(serverTime: string | undefined, now = Date.now()): number {
  if (!serverTime) return 0;
  const parsed = Date.parse(serverTime);
  return Number.isNaN(parsed) ? 0 : parsed - now;
}

/** `auth_dto.AppConfig` → store shakli. */
export function toAppConfigState(config: AppConfig, now = Date.now()) {
  return {
    clockSkewMs: computeClockSkewMs(config.server_time, now),
    featureFlags: config.feature_flags ?? {},
    accessTokenTtlSeconds: config.access_token_ttl_seconds ?? 900,
    supportEmail: config.support_email ?? null,
    loaded: true,
  };
}

/** `company_dto.Company` → formatlash konteksti. */
export function toCompanyContext(company: Company) {
  return {
    id: company.id ?? null,
    name: company.name ?? null,
    region: company.region ?? null,
    unitSystem: company.unit_system === 'metric' ? ('metric' as const) : ('imperial' as const),
    regulationProfile: company.regulation_profile ?? DEFAULT_COMPANY_CONTEXT.regulationProfile,
    timezone: company.timezone ?? DEFAULT_COMPANY_CONTEXT.timezone,
  };
}

/** Bootstrap natijasi — router shu bo'yicha `/login` yoki ilovani ko'rsatadi. */
export interface BootstrapResult {
  authenticated: boolean;
  /** Cheklangan sessiya: 2FA enrolment tugallanishi kerak. */
  limited: boolean;
}

async function restoreSession(): Promise<boolean> {
  if (authState().accessToken !== null) return true;
  if (!hasStoredRefreshToken()) return false;

  const outcome = await refreshTokens();
  return outcome.ok;
}

async function loadCompanyContext(permissions: readonly string[]): Promise<void> {
  if (!permissions.includes(PERM.companyRead)) return;

  try {
    companyState().setCompany(toCompanyContext(await fetchCompany()));
  } catch (error) {
    // Kompaniya konteksti yo'qligi ilovani bloklamaydi — default qiymatlar
    // (imperial / generic / UTC) bilan davom etadi.
    console.warn('[bootstrap] Company context could not be loaded', error);
  }
}

/**
 * Ochiq sessiya uchun profil + ruxsatlar + kompaniya kontekstini yuklaydi.
 *
 * Bootstrap'dan **tashqarida** ham kerak: login / 2FA verify / 2FA setup
 * tokenlarni qo'llagach yangi sessiya ochadi, lekin `BootstrapGate` allaqachon
 * ishlab bo'lgan va qayta ishga tushmaydi. Shu funksiya chaqirilmasa
 * `profile` `null` qoladi → ruxsatlar bo'sh → foydalanuvchi darhol 403 ga
 * tushadi (D49). Shuning uchun sessiya ochadigan har bir oqim navigatsiyadan
 * **oldin** shuni kutishi shart.
 *
 * `401`/`403` — sessiya haqiqiy emas: anonim holatga tushiladi (xato emas).
 */
export async function loadSessionContext(): Promise<BootstrapResult> {
  try {
    const profile = await fetchProfile();
    authState().setProfile(profile);
    await loadCompanyContext(profile.permissions ?? []);
    return { authenticated: true, limited: authState().limited };
  } catch (error) {
    if (isApiError(error) && (error.status === 401 || error.status === 403)) {
      endSession('session_expired');
      return { authenticated: false, limited: false };
    }
    throw error;
  }
}

/**
 * Bootstrap'ni bajaradi. `GET /app/config` yiqilsa xato **otiladi** —
 * chaqiruvchi to'liq ekranli xato holatini ko'rsatadi.
 */
export async function runBootstrap(): Promise<BootstrapResult> {
  purgeLegacyTokenStorage();

  companyState().setAppConfig(toAppConfigState(await fetchAppConfig()));

  if (!(await restoreSession())) {
    return { authenticated: false, limited: false };
  }

  return loadSessionContext();
}
