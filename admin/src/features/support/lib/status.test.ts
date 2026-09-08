import { describe, expect, it } from 'vitest';

import { nextSupportTicketStatuses, supportTicketStatusBadgeTone } from './status';

describe('nextSupportTicketStatuses', () => {
  it('offers the remaining forward states from "new"', () => {
    expect(nextSupportTicketStatuses('new')).toEqual(['in_progress', 'resolved']);
  });

  it('offers only "resolved" from "in_progress"', () => {
    expect(nextSupportTicketStatuses('in_progress')).toEqual(['resolved']);
  });

  it('offers nothing once resolved or closed (forward-only lifecycle)', () => {
    expect(nextSupportTicketStatuses('resolved')).toEqual([]);
    expect(nextSupportTicketStatuses('closed')).toEqual([]);
  });

  it('offers nothing for an unknown/missing status', () => {
    expect(nextSupportTicketStatuses(undefined)).toEqual([]);
  });
});

describe('supportTicketStatusBadgeTone', () => {
  it('maps each status to its semantic tone', () => {
    expect(supportTicketStatusBadgeTone('new')).toBe('info');
    expect(supportTicketStatusBadgeTone('in_progress')).toBe('warning');
    expect(supportTicketStatusBadgeTone('resolved')).toBe('success');
    expect(supportTicketStatusBadgeTone('closed')).toBe('neutral');
  });
});
