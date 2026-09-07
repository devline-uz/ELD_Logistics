import { selectScope, useAuthStore } from '@/store/auth-store';

/**
 * Sessiya `scope`i (`company | branch | self`). Branch select/filtrini
 * faqat `scope=company` administratoriga ko'rsatish uchun ishlatiladi
 * (bosqich 2 ko'rigi B1) — `docs/tz/07-3-fleet.md` §7.3.1/§7.3.4/§7.3.9.
 */
export function useScope() {
  return useAuthStore(selectScope);
}

/** Qulaylik uchun: joriy foydalanuvchi `scope=company` ekanini tekshiradi. */
export function useIsCompanyScope(): boolean {
  return useScope() === 'company';
}
