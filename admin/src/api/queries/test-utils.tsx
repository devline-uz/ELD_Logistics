/**
 * Query hook testlari uchun umumiy `QueryClientProvider` wrapper (2.1).
 * Testlarda qayta urinish o'chirilgan — xato holatlari darhol aniqlanadi.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import type { ReactElement, ReactNode } from 'react';

export function createTestQueryClient(): QueryClient {
  return new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });
}

export function withQueryClient(client: QueryClient = createTestQueryClient()) {
  return function Wrapper({ children }: { children: ReactNode }): ReactElement {
    return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
  };
}
