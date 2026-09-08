import type { RouteObject } from 'react-router-dom';

import { guardedRoute } from '@/app/router/route-helpers';
import { PERM } from '@/lib/permissions';

/** Support & History guruhi: Histories (`/audit`), Contact Support, Feedback (8.8–8.10). */
export const supportRoutes: RouteObject[] = [
  guardedRoute(
    'audit',
    async () => (await import('@/features/audit/pages/AuditListPage')).AuditListPage,
    { permission: PERM.auditView },
  ),
  guardedRoute(
    'support',
    async () => (await import('@/features/support/pages/SupportListPage')).SupportListPage,
    { permission: PERM.supportRead },
  ),
  guardedRoute(
    'support/:id',
    async () => (await import('@/features/support/pages/SupportDetailPage')).SupportDetailPage,
    { permission: PERM.supportRead },
  ),
  guardedRoute(
    'feedback',
    async () => (await import('@/features/support/pages/FeedbackListPage')).FeedbackListPage,
    { permission: PERM.feedbackRead },
  ),
  guardedRoute(
    'inspection',
    async () => (await import('@/features/audit/pages/InspectionLogsPage')).InspectionLogsPage,
    { permission: PERM.inspectionView },
  ),
];
