/**
 * Sessiya bayroqlari (`subscription_readonly`, `replaced_session`) —
 * `POST /auth/login` javobining bir qismi, shuning uchun **auth store**da
 * yashaydi (`src/store/auth-store.ts`), alohida React Context'da emas.
 *
 * Ilgari bu qiymatlar `SessionFlagsProvider` orqali props sifatida
 * uzatilardi (`initial` prop). Bu boshqa har qanday sessiya holatidan
 * (access token, profil) ajralib turardi va testlarda butun provayder
 * daraxtini (`AppProviders` → `BootstrapGate` → ...) qurishni talab qilardi.
 * Endi testlar `useAuthStore.setState({ subscriptionReadonly, replacedSession })`
 * bilan to'g'ridan-to'g'ri sozlaydi.
 */
import { useAuthStore, type AuthState } from '@/store/auth-store';

export type SessionFlags = Pick<AuthState, 'subscriptionReadonly' | 'replacedSession'>;

export interface SessionFlagsApi extends SessionFlags {
  setSessionFlags: (flags: Partial<SessionFlags>) => void;
}

/**
 * Auth store'dagi sessiya bayroqlari + ularni yangilash funksiyasi.
 *
 * Har bayroq **alohida** selektor bilan o'qiladi (obyekt qaytaruvchi bitta
 * selektor emas) — zustand standart taqqoslashi referens bo'yicha bo'lgani
 * uchun har render yangi obyekt cheksiz qayta render'ga olib kelardi.
 */
export function useSessionFlags(): SessionFlagsApi {
  const subscriptionReadonly = useAuthStore((state) => state.subscriptionReadonly);
  const replacedSession = useAuthStore((state) => state.replacedSession);
  const setSessionFlags = useAuthStore((state) => state.setSessionFlags);
  return { subscriptionReadonly, replacedSession, setSessionFlags };
}
