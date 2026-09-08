import { describe, expect, it } from 'vitest';

import type { Notification } from '@/api/types';

import { groupNotificationsByDay } from './groupByDay';

const LABELS = { today: 'Today', yesterday: 'Yesterday' };

function fixture(overrides: Partial<Notification>): Notification {
  return {
    id: 'n1',
    alert_type: 'hos_warning',
    title: 't',
    body: 'b',
    channels: ['in_app'],
    entity_type: undefined,
    entity_id: undefined,
    read: false,
    sent_at: overrides.created_at,
    created_at: '2026-09-08T10:00:00Z',
    ...overrides,
  };
}

// Fake formatDate: simply returns the ISO calendar day, ignoring TZ nuance —
// exercises the grouping logic itself (day labels come from the caller).
function fakeFormatDate(value: string | Date | null | undefined): string {
  if (!value) return 'N/A';
  const date = typeof value === 'string' ? new Date(value) : value;
  return date.toISOString().slice(0, 10);
}

describe('groupNotificationsByDay', () => {
  const now = new Date('2026-09-08T18:00:00Z');

  it('labels items from today and yesterday, and groups the rest by date', () => {
    const items = [
      fixture({ id: 'a', created_at: '2026-09-08T09:00:00Z' }),
      fixture({ id: 'b', created_at: '2026-09-07T09:00:00Z' }),
      fixture({ id: 'c', created_at: '2026-09-05T09:00:00Z' }),
    ];

    const groups = groupNotificationsByDay(items, fakeFormatDate, LABELS, now);

    expect(groups).toHaveLength(3);
    expect(groups[0]).toMatchObject({ label: 'Today' });
    expect(groups[0]?.items.map((n) => n.id)).toEqual(['a']);
    expect(groups[1]).toMatchObject({ label: 'Yesterday' });
    expect(groups[2]?.label).toBe('2026-09-05');
  });

  it('keeps multiple items from the same day in a single group, in input order', () => {
    const items = [
      fixture({ id: 'a', created_at: '2026-09-08T09:00:00Z' }),
      fixture({ id: 'b', created_at: '2026-09-08T08:00:00Z' }),
    ];

    const groups = groupNotificationsByDay(items, fakeFormatDate, LABELS, now);

    expect(groups).toHaveLength(1);
    expect(groups[0]?.items.map((n) => n.id)).toEqual(['a', 'b']);
  });

  it('returns an empty array for an empty list', () => {
    expect(groupNotificationsByDay([], fakeFormatDate, LABELS, now)).toEqual([]);
  });
});
