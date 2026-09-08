import { describe, expect, it } from 'vitest';

import { resolveDateGroupKind } from './dateGroups';

const TZ = 'UTC';
const NOW = new Date('2026-09-08T12:00:00Z');

describe('resolveDateGroupKind', () => {
  it('returns "today" for a timestamp on the same calendar day', () => {
    expect(resolveDateGroupKind('2026-09-08T03:00:00Z', TZ, NOW)).toBe('today');
  });

  it('returns "yesterday" for the previous calendar day', () => {
    expect(resolveDateGroupKind('2026-09-07T23:00:00Z', TZ, NOW)).toBe('yesterday');
  });

  it('returns "weekday" for 2-6 days ago', () => {
    expect(resolveDateGroupKind('2026-09-04T10:00:00Z', TZ, NOW)).toBe('weekday');
  });

  it('returns "older" for 7+ days ago', () => {
    expect(resolveDateGroupKind('2026-08-01T10:00:00Z', TZ, NOW)).toBe('older');
  });

  it('returns "older" for an undefined value', () => {
    expect(resolveDateGroupKind(undefined, TZ, NOW)).toBe('older');
  });
});
