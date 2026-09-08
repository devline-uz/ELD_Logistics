import { useEffect, useRef, type ReactNode } from 'react';
import { useTranslation } from 'react-i18next';

import { useSessionFlags } from '@/app/providers/session-flags-context';
import { useToast } from '@/components/feedback/toast-context';

export interface SessionFlagsProviderProps {
  children: ReactNode;
}

/**
 * `replaced_session` bir martalik toast'i (0.22).
 *
 * Bayroqning o'zi endi auth store'da (`session-flags-context.ts`) — bu
 * komponent faqat "boshqa web sessiya yopildi" toast'ini bir marta
 * ko'rsatish yon ta'sirini boshqaradi, hech qanday Context taqdim etmaydi.
 */
export function SessionFlagsProvider({ children }: SessionFlagsProviderProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const { replacedSession } = useSessionFlags();
  const replacedNotified = useRef(false);

  useEffect(() => {
    if (replacedSession && !replacedNotified.current) {
      replacedNotified.current = true;
      toast.show({ variant: 'warning', message: t('toast.replacedSession') });
    }
    if (!replacedSession) {
      replacedNotified.current = false;
    }
  }, [replacedSession, toast, t]);

  return <>{children}</>;
}

export default SessionFlagsProvider;
