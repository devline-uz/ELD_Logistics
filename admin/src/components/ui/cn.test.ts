import { describe, expect, it } from 'vitest';

import { cn } from './cn';

describe('cn', () => {
  it('joins truthy string values with a space', () => {
    expect(cn('a', 'b')).toBe('a b');
  });

  it('drops falsy values (false, null, undefined, empty string, 0)', () => {
    expect(cn('a', false, null, undefined, '', 0, 'b')).toBe('a b');
  });

  it('flattens nested arrays', () => {
    expect(cn('a', ['b', ['c', false, 'd']], 'e')).toBe('a b c d e');
  });

  it('returns an empty string when nothing is truthy', () => {
    expect(cn(false, null, undefined)).toBe('');
  });
});
