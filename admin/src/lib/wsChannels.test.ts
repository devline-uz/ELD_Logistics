import { describe, expect, it } from 'vitest';

import {
  type ChannelSubscriber,
  createChannelState,
  isDuplicateEvent,
  mergeFilters,
} from './wsChannels';

function subscriber(filter?: ChannelSubscriber['filter']): ChannelSubscriber {
  return { id: Math.random(), filter, onEvent: () => undefined };
}

describe('mergeFilters', () => {
  it('returns undefined (subscribe to all) when any subscriber has no filter', () => {
    const result = mergeFilters([subscriber({ unit_ids: ['u1'] }), subscriber(undefined)]);
    expect(result).toBeUndefined();
  });

  it('unions and dedupes unit_ids across subscribers', () => {
    const result = mergeFilters([
      subscriber({ unit_ids: ['u1', 'u2'] }),
      subscriber({ unit_ids: ['u2', 'u3'] }),
    ]);
    expect(result).toEqual({ unit_ids: ['u1', 'u2', 'u3'] });
  });

  it('caps ids at 500', () => {
    const many = Array.from({ length: 600 }, (_, i) => `u${i}`);
    const result = mergeFilters([subscriber({ unit_ids: many })]);
    expect(result?.unit_ids).toHaveLength(500);
  });

  it('unions and dedupes driver_ids the same way as unit_ids', () => {
    const result = mergeFilters([
      subscriber({ driver_ids: ['d1', 'd2'] }),
      subscriber({ driver_ids: ['d2', 'd3'] }),
    ]);
    expect(result).toEqual({ driver_ids: ['d1', 'd2', 'd3'] });
  });

  it('returns undefined (subscribe to all) when a filter has neither unit_ids nor driver_ids', () => {
    const result = mergeFilters([subscriber({})]);
    expect(result).toBeUndefined();
  });

  it('returns undefined when the only ids provided are empty arrays', () => {
    const result = mergeFilters([subscriber({ driver_ids: [] })]);
    expect(result).toBeUndefined();
  });

  it('returns undefined for an empty subscriber iterable', () => {
    expect(mergeFilters([])).toBeUndefined();
  });
});

describe('isDuplicateEvent', () => {
  it('treats an event with an equal or older ts as duplicate', () => {
    const channel = createChannelState();
    expect(isDuplicateEvent(channel, { type: 'x', data: {}, ts: '2026-01-01T00:00:00Z' })).toBe(
      false,
    );
    expect(isDuplicateEvent(channel, { type: 'x', data: {}, ts: '2026-01-01T00:00:00Z' })).toBe(
      true,
    );
    expect(isDuplicateEvent(channel, { type: 'x', data: {}, ts: '2025-12-31T00:00:00Z' })).toBe(
      true,
    );
    expect(isDuplicateEvent(channel, { type: 'x', data: {}, ts: '2026-01-02T00:00:00Z' })).toBe(
      false,
    );
  });

  it('treats a repeated id as duplicate regardless of ts', () => {
    const channel = createChannelState();
    expect(
      isDuplicateEvent(channel, { type: 'x', data: {}, id: 'e1', ts: '2026-01-01T00:00:00Z' }),
    ).toBe(false);
    expect(
      isDuplicateEvent(channel, { type: 'x', data: {}, id: 'e1', ts: '2026-01-02T00:00:00Z' }),
    ).toBe(true);
  });

  it('detects a duplicate by id without requiring a ts', () => {
    const channel = createChannelState();
    expect(isDuplicateEvent(channel, { type: 'x', data: {}, id: 'e1' })).toBe(false);
    expect(channel.lastTs).toBeUndefined();
    expect(isDuplicateEvent(channel, { type: 'x', data: {}, id: 'e1' })).toBe(true);
  });

  it('caps the seen-id cache at MAX_SEEN_IDS, evicting the oldest first', () => {
    const channel = createChannelState();
    for (let i = 0; i < 205; i += 1) {
      isDuplicateEvent(channel, { type: 'x', data: {}, id: `id-${i}` });
    }
    expect(channel.seenIds).toHaveLength(200);
    expect(channel.seenIds).not.toContain('id-0');
    expect(channel.seenIds).toContain('id-204');
  });
});
