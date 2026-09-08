/**
 * Support ticket status — forward-only lifecycle (`docs/tz/07-9-chat-support-audit.md`
 * §7.10.1, swagger `TicketStatusUpdate`).
 *
 * Backend accepts `new → in_progress → resolved` only (`PATCH
 * /support-tickets/{id}/status`); `closed` exists as a read state
 * (`Ticket.status` enum) but is never a target of this endpoint — any
 * backward/repeated transition answers `409 INVALID_STATE`.
 */
import type { BadgeTone } from '@/components/ui/Badge';

/** All four read states (list/detail filter — F135, `In Progress` display). */
export const SUPPORT_TICKET_STATUSES = ['new', 'in_progress', 'resolved', 'closed'] as const;
export type SupportTicketStatus = (typeof SUPPORT_TICKET_STATUSES)[number];

/** Statuses the `PATCH .../status` endpoint accepts as a body, in forward order. */
const FORWARD_FLOW: readonly SupportTicketStatus[] = ['new', 'in_progress', 'resolved'];

/**
 * Statuses still reachable from `current` (forward-only). Empty once the
 * ticket is `resolved` or `closed` — the status-change action is hidden.
 */
export function nextSupportTicketStatuses(current: string | undefined): SupportTicketStatus[] {
  const index = FORWARD_FLOW.indexOf(current as SupportTicketStatus);
  if (index === -1) return [];
  return FORWARD_FLOW.slice(index + 1);
}

/** Badge tone per status (fe-design-system §1 semantic map). */
export function supportTicketStatusBadgeTone(status: string | undefined): BadgeTone {
  switch (status) {
    case 'resolved':
      return 'success';
    case 'in_progress':
      return 'warning';
    case 'closed':
      return 'neutral';
    default:
      return 'info';
  }
}
