import type { RouteObject } from 'react-router-dom';

import { guardedRoute } from '@/app/router/route-helpers';
import { PERM } from '@/lib/permissions';

const load = () => import('@/features/support/pages/stubs');

/** Support & History guruhi: Histories (`/audit`), Contact Support, Feedback. */
export const supportRoutes: RouteObject[] = [
  guardedRoute('audit', async () => (await import('@/features/audit/pages/stubs')).AuditPage, {
    permission: PERM.auditView,
  }),
  guardedRoute('support', async () => (await load()).SupportPage, {
    permission: PERM.supportRead,
  }),
  guardedRoute('feedback', async () => (await load()).FeedbackPage, {
    permission: PERM.feedbackRead,
  }),
];
