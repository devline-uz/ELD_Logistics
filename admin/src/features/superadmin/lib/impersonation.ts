/**
 * Super Admin — tenant almashtirish (impersonatsiya) yordamchilari (9.15,
 * §7.14, F152).
 *
 * Haqiqat manbai — `authState().impersonatedCompanyId` (`@/api/session`,
 * `X-Company-Id` header'i shu yerdan o'qiladi). Bu modul faqat bannerda
 * ko'rsatiladigan kompaniya **nomini** saqlaydi — `GET /companies/{id}` yo'q
 * (D55), shuning uchun nom ro'yxat qatoridan olib shu yerga qo'yiladi va
 * chiqilganda/sessiya tugaganda tozalanadi.
 */
import { create } from 'zustand';

import { onSessionEnded, setCompanyId } from '@/api/session';
import type { AdminCompany } from '@/api/types';

interface ImpersonationState {
  companyName: string | null;
  setCompanyName: (name: string | null) => void;
}

export const useImpersonationStore = create<ImpersonationState>((set) => ({
  companyName: null,
  setCompanyName: (companyName) => set({ companyName }),
}));

onSessionEnded(() => {
  useImpersonationStore.getState().setCompanyName(null);
});

/** "Enter" — F152: `X-Company-Id` o'rnatiladi, banner kompaniya nomini ko'rsatadi. */
export function enterCompany(company: AdminCompany): void {
  if (!company.id) return;
  setCompanyId(company.id);
  useImpersonationStore.getState().setCompanyName(company.name ?? null);
}

/** "Exit" — tenant konteksti tozalanadi (D54: kesh/WS reseti `onCompanyChanged` orqali). */
export function exitCompany(): void {
  setCompanyId(null);
  useImpersonationStore.getState().setCompanyName(null);
}
