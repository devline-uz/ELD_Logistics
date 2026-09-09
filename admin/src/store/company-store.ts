/**
 * Kompaniya konteksti va ilova konfiguratsiyasi (0.14 / 0.15).
 *
 * Auth store'dan **alohida** saqlanadi, chunki bu ma'lumot formatlash qatlami
 * uchun kerak: `lib/format.ts` (sana/vaqt — kompaniya `timezone` sida, D-f6) va
 * `lib/units.ts` (masofa/hajm — `unit_system` bo'yicha) shu store'dan o'qiydi.
 * Ikkalasi ham React komponenti emas, shuning uchun React'siz `companyState()`
 * getter'i ham berilgan.
 *
 * Manbalar:
 * - `GET /company` → `region`, `unit_system`, `regulation_profile`, `timezone`;
 * - `GET /app/config` (public) → `server_time` (soat siljishi), `feature_flags`,
 *   `access_token_ttl_seconds`.
 */
import { create } from 'zustand';

/** Kompaniya formatlash konteksti. */
export interface CompanyContext {
  id: string | null;
  name: string | null;
  /** `PK | UZ | US | other` — masofa hisobotining mintaqa katalogini tanlaydi. */
  region: string | null;
  /** `metric | imperial` — `lib/units.ts` konversiyasi. */
  unitSystem: 'metric' | 'imperial';
  /** `us_fmcsa | generic | canada | texas | california | alaska | hawaii`. */
  regulationProfile: string;
  /** IANA zona nomi — barcha sana shu zonada ko'rsatiladi (F193 / D-f6). */
  timezone: string;
}

/**
 * Kompaniya konteksti hali kelmaganda (login qilinmagan yoki `company.read`
 * ruxsati yo'q) ishlatiladigan neytral qiymatlar.
 */
export const DEFAULT_COMPANY_CONTEXT: CompanyContext = Object.freeze({
  id: null,
  name: null,
  region: null,
  unitSystem: 'imperial',
  regulationProfile: 'generic',
  timezone: 'UTC',
});

/** `GET /app/config` dan olinadigan ilova konfiguratsiyasi. */
export interface AppConfigState {
  /** `server_time − Date.now()` (ms). Musbat — klient soati orqada. */
  clockSkewMs: number;
  /** Modullarni yoqib-o'chiruvchi bayroqlar. */
  featureFlags: Readonly<Record<string, boolean>>;
  /** Access token TTL (sekund) — proaktiv refresh taymerining zaxira qiymati. */
  accessTokenTtlSeconds: number;
  supportEmail: string | null;
  /** Konfiguratsiya muvaffaqiyatli yuklanganmi. */
  loaded: boolean;
}

export const DEFAULT_APP_CONFIG: AppConfigState = Object.freeze({
  clockSkewMs: 0,
  featureFlags: Object.freeze({}),
  accessTokenTtlSeconds: 900,
  supportEmail: null,
  loaded: false,
});

export interface CompanyStoreState {
  company: CompanyContext;
  appConfig: AppConfigState;
  setCompany: (company: Partial<CompanyContext> | null) => void;
  setAppConfig: (config: Partial<AppConfigState>) => void;
  /** Logout — kompaniya konteksti tozalanadi, `appConfig` (public) qoladi. */
  resetCompany: () => void;
}

export const useCompanyStore = create<CompanyStoreState>((set) => ({
  company: DEFAULT_COMPANY_CONTEXT,
  appConfig: DEFAULT_APP_CONFIG,

  setCompany: (company) =>
    set({
      company: company ? { ...DEFAULT_COMPANY_CONTEXT, ...company } : DEFAULT_COMPANY_CONTEXT,
    }),

  setAppConfig: (config) => set((state) => ({ appConfig: { ...state.appConfig, ...config } })),

  resetCompany: () => set({ company: DEFAULT_COMPANY_CONTEXT }),
}));

/** React'dan tashqarida o'qish uchun (`lib/format.ts`, `lib/units.ts`). */
export function companyState(): CompanyStoreState {
  return useCompanyStore.getState();
}

/** Joriy kompaniya konteksti — React'siz. */
export function getCompanyContext(): CompanyContext {
  return companyState().company;
}
