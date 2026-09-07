import { createContext, useContext } from 'react';

/** `POST /auth/login` javobidagi sessiya bayroqlari (fe-api §4). */
export interface SessionFlags {
  /** Obuna muddati tugagan — barcha yozuv amallari bloklanadi (F35). */
  subscriptionReadonly: boolean;
  /** Boshqa web sessiya majburan yopilgan — bir martalik toast. */
  replacedSession: boolean;
}

export interface SessionFlagsApi extends SessionFlags {
  setSessionFlags: (flags: Partial<SessionFlags>) => void;
}

export const DEFAULT_SESSION_FLAGS: SessionFlags = {
  subscriptionReadonly: false,
  replacedSession: false,
};

export const SessionFlagsContext = createContext<SessionFlagsApi>({
  ...DEFAULT_SESSION_FLAGS,
  setSessionFlags: () => undefined,
});

export function useSessionFlags(): SessionFlagsApi {
  return useContext(SessionFlagsContext);
}
