import { QueryClientProvider, type QueryClient } from '@tanstack/react-query';
import { useEffect, useMemo, type ReactNode } from 'react';

import { onSessionEnded } from '@/api/session';
import { createQueryClient } from '@/app/providers/query-client';

export interface QueryProviderProps {
  /** Testda o'z klientini berish uchun. */
  client?: QueryClient;
  children: ReactNode;
}

/**
 * TanStack Query provayderi (0.12).
 *
 * Sessiya tugaganda (logout, idle timeout, refresh reuse detection) kesh
 * **to'liq tozalanadi** — aks holda keyingi foydalanuvchi oldingi sessiyaning
 * ma'lumotini bir lahza ko'rib qolishi mumkin (fe-api §4, F16 qadam 1).
 */
export function QueryProvider({ client, children }: QueryProviderProps) {
  const queryClient = useMemo(() => client ?? createQueryClient(), [client]);

  useEffect(() => onSessionEnded(() => queryClient.clear()), [queryClient]);

  return <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>;
}

export default QueryProvider;
