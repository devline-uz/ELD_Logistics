import { useCallback, useEffect, useMemo, useRef, useState, type ReactNode } from 'react';
import { useTranslation } from 'react-i18next';

import {
  DEFAULT_SESSION_FLAGS,
  SessionFlagsContext,
  type SessionFlags,
  type SessionFlagsApi,
} from '@/app/providers/session-flags-context';
import { useToast } from '@/components/feedback/toast-context';

export interface SessionFlagsProviderProps {
  /** Boshlang'ich qiymat — auth store (0.12) ulangach login javobidan keladi. */
  initial?: Partial<SessionFlags>;
  children: ReactNode;
}

/**
 * `subscription_readonly` va `replaced_session` bayroqlari (0.22).
 * `replaced_session` — bir martalik toast, banner emas.
 */
export function SessionFlagsProvider({ initial, children }: SessionFlagsProviderProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const [flags, setFlags] = useState<SessionFlags>({ ...DEFAULT_SESSION_FLAGS, ...initial });
  const replacedNotified = useRef(false);

  useEffect(() => {
    if (flags.replacedSession && !replacedNotified.current) {
      replacedNotified.current = true;
      toast.show({ variant: 'warning', message: t('toast.replacedSession') });
    }
  }, [flags.replacedSession, toast, t]);

  const setSessionFlags = useCallback((partial: Partial<SessionFlags>) => {
    setFlags((current) => ({ ...current, ...partial }));
  }, []);

  const value = useMemo<SessionFlagsApi>(
    () => ({ ...flags, setSessionFlags }),
    [flags, setSessionFlags],
  );

  return <SessionFlagsContext.Provider value={value}>{children}</SessionFlagsContext.Provider>;
}
