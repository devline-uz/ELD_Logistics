import type { RouteObject } from 'react-router-dom';

import { guardedRoute } from '@/app/router/route-helpers';
import { PERM } from '@/lib/permissions';

export const chatRoutes: RouteObject[] = [
  guardedRoute('chat', async () => (await import('@/features/chat/pages/ChatPage')).ChatPage, {
    permission: PERM.chatRead,
  }),
];
