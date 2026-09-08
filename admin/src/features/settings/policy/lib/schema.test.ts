import { describe, expect, it } from 'vitest';

import { hosPolicyFormSchema } from './schema';

const VALID = {
  drive_limit_min: 660,
  shift_window_min: 840,
  break_required_after_drive_min: 480,
  break_duration_min: 30,
  break_qualifying_statuses: ['OFF', 'SB', 'ON'] as const,
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

describe('hosPolicyFormSchema', () => {
  it('accepts a valid FMCSA 70/8-shaped policy', () => {
    expect(hosPolicyFormSchema.safeParse(VALID).success).toBe(true);
  });

  it('rejects a negative drive_limit_min', () => {
    const result = hosPolicyFormSchema.safeParse({ ...VALID, drive_limit_min: -1 });
    expect(result.success).toBe(false);
  });

  it('accepts the boundary value 0 for drive_limit_min', () => {
    expect(hosPolicyFormSchema.safeParse({ ...VALID, drive_limit_min: 0 }).success).toBe(true);
  });

  it('accepts the boundary value 1440 (24h) for shift_window_min', () => {
    expect(hosPolicyFormSchema.safeParse({ ...VALID, shift_window_min: 1440 }).success).toBe(true);
  });

  it('rejects 1441 for shift_window_min (over the 24h guardrail)', () => {
    expect(hosPolicyFormSchema.safeParse({ ...VALID, shift_window_min: 1441 }).success).toBe(false);
  });

  it('accepts a multi-day cycle_limit_min up to 10080 (7 days)', () => {
    expect(hosPolicyFormSchema.safeParse({ ...VALID, cycle_limit_min: 10080 }).success).toBe(true);
  });

  it('rejects cycle_limit_min above 10080', () => {
    expect(hosPolicyFormSchema.safeParse({ ...VALID, cycle_limit_min: 10081 }).success).toBe(false);
  });

  it('rejects cycle_days below 1', () => {
    expect(hosPolicyFormSchema.safeParse({ ...VALID, cycle_days: 0 }).success).toBe(false);
  });

  it('rejects cycle_days above 14', () => {
    expect(hosPolicyFormSchema.safeParse({ ...VALID, cycle_days: 15 }).success).toBe(false);
  });

  it('rejects an empty break_qualifying_statuses array', () => {
    expect(hosPolicyFormSchema.safeParse({ ...VALID, break_qualifying_statuses: [] }).success).toBe(
      false,
    );
  });

  it('rejects a non-integer cycle_days', () => {
    expect(hosPolicyFormSchema.safeParse({ ...VALID, cycle_days: 7.5 }).success).toBe(false);
  });

  it('rejects a negative ym_max_speed_kmh', () => {
    expect(hosPolicyFormSchema.safeParse({ ...VALID, ym_max_speed_kmh: -1 }).success).toBe(false);
  });

  it('accepts ym_max_speed_kmh at the 200 upper boundary', () => {
    expect(hosPolicyFormSchema.safeParse({ ...VALID, ym_max_speed_kmh: 200 }).success).toBe(true);
  });
});
