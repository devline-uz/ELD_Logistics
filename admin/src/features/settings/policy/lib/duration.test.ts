import { describe, expect, it } from 'vitest';

import { formatHm, hmToMinutes, minutesToHm } from './duration';

describe('minutesToHm', () => {
  it('converts 0 minutes', () => {
    expect(minutesToHm(0)).toEqual({ hours: 0, minutes: 0 });
  });

  it('keeps minutes under an hour', () => {
    expect(minutesToHm(59)).toEqual({ hours: 0, minutes: 59 });
  });

  it('rolls over exactly one hour', () => {
    expect(minutesToHm(60)).toEqual({ hours: 1, minutes: 0 });
  });

  it('supports multi-day durations (8-day cycle, 70h)', () => {
    expect(minutesToHm(4200)).toEqual({ hours: 70, minutes: 0 });
  });

  it('clamps negative/NaN input to zero', () => {
    expect(minutesToHm(-15)).toEqual({ hours: 0, minutes: 0 });
    expect(minutesToHm(Number.NaN)).toEqual({ hours: 0, minutes: 0 });
  });

  it('truncates fractional minutes', () => {
    expect(minutesToHm(90.9)).toEqual({ hours: 1, minutes: 30 });
  });
});

describe('hmToMinutes', () => {
  it('converts back to minutes', () => {
    expect(hmToMinutes({ hours: 11, minutes: 0 })).toBe(660);
  });

  it('handles zero', () => {
    expect(hmToMinutes({ hours: 0, minutes: 0 })).toBe(0);
  });

  it('carries overflow minutes (>59) into hours', () => {
    expect(hmToMinutes({ hours: 1, minutes: 65 })).toBe(125);
  });

  it('clamps negative components to zero', () => {
    expect(hmToMinutes({ hours: -2, minutes: -5 })).toBe(0);
  });

  it('round-trips with minutesToHm', () => {
    expect(hmToMinutes(minutesToHm(4200))).toBe(4200);
    expect(hmToMinutes(minutesToHm(0))).toBe(0);
    expect(hmToMinutes(minutesToHm(59))).toBe(59);
  });
});

describe('formatHm', () => {
  it('pads hours and minutes to two digits', () => {
    expect(formatHm(90)).toBe('01:30');
  });

  it('does not cap hours at 24 (multi-day cycle)', () => {
    expect(formatHm(4200)).toBe('70:00');
  });

  it('formats zero', () => {
    expect(formatHm(0)).toBe('00:00');
  });
});
