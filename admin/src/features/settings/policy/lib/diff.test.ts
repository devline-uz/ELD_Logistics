import { describe, expect, it } from 'vitest';

import type { HosPolicyDoc } from '@/api/types';

import { diffHosPolicy } from './diff';

const BASE: HosPolicyDoc = {
  drive_limit_min: 660,
  shift_window_min: 840,
  break_required_after_drive_min: 480,
  break_duration_min: 30,
  break_qualifying_statuses: ['OFF', 'SB', 'ON'],
  daily_rest_min: 600,
  cycle_limit_min: 4200,
  cycle_days: 8,
  cycle_restart_min: 2040,
  sleeper_split_enabled: true,
  sleeper_berth_available: true,
  allow_pc: true,
  allow_ym: true,
  ym_max_speed_kmh: 32,
  motion_threshold_kmh: 8,
  warning_thresholds: { break: 30, cycle: 120, drive: 30, shift: 60 },
  short_haul_exception: false,
  adverse_conditions_extension_min: 120,
};

describe('diffHosPolicy', () => {
  it('returns no entries for identical policies', () => {
    expect(diffHosPolicy(BASE, { ...BASE })).toEqual([]);
  });

  it('detects a scalar change', () => {
    const after = { ...BASE, drive_limit_min: 600 };
    expect(diffHosPolicy(BASE, after)).toEqual([
      { field: 'drive_limit_min', oldValue: 660, newValue: 600 },
    ]);
  });

  it('detects a boolean change', () => {
    const after = { ...BASE, allow_pc: false };
    expect(diffHosPolicy(BASE, after)).toEqual([
      { field: 'allow_pc', oldValue: true, newValue: false },
    ]);
  });

  it('ignores array order when comparing break_qualifying_statuses', () => {
    const after: HosPolicyDoc = { ...BASE, break_qualifying_statuses: ['SB', 'ON', 'OFF'] };
    expect(diffHosPolicy(BASE, after)).toEqual([]);
  });

  it('detects a break_qualifying_statuses content change', () => {
    const after: HosPolicyDoc = { ...BASE, break_qualifying_statuses: ['OFF', 'SB'] };
    expect(diffHosPolicy(BASE, after)).toEqual([
      {
        field: 'break_qualifying_statuses',
        oldValue: ['OFF', 'SB', 'ON'],
        newValue: ['OFF', 'SB'],
      },
    ]);
  });

  it('detects nested warning_thresholds changes with dotted field name', () => {
    const after = {
      ...BASE,
      warning_thresholds: { ...BASE.warning_thresholds, drive: 45 },
    };
    expect(diffHosPolicy(BASE, after)).toEqual([
      { field: 'warning_thresholds.drive', oldValue: 30, newValue: 45 },
    ]);
  });

  it('handles undefined before/after gracefully', () => {
    expect(diffHosPolicy(undefined, undefined)).toEqual([]);
    expect(diffHosPolicy(undefined, { drive_limit_min: 660 })).toEqual([
      { field: 'drive_limit_min', oldValue: undefined, newValue: 660 },
    ]);
  });

  it('collects multiple simultaneous changes', () => {
    const after = { ...BASE, drive_limit_min: 600, cycle_days: 7, cycle_limit_min: 3600 };
    const entries = diffHosPolicy(BASE, after);
    expect(entries).toHaveLength(3);
    expect(entries.map((entry) => entry.field).sort()).toEqual(
      ['cycle_days', 'cycle_limit_min', 'drive_limit_min'].sort(),
    );
  });
});
