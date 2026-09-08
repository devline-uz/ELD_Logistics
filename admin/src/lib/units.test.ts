import { describe, expect, it } from 'vitest';

import {
  formatDistance,
  formatSpeed,
  formatTemperature,
  formatVolume,
  formatWeight,
  parseDistance,
  parseSpeed,
  parseTemperature,
  parseVolume,
  parseWeight,
} from './units';

describe('formatDistance', () => {
  it('formats metric (km, 1 decimal) from meters', () => {
    expect(formatDistance(193_000, 'metric')).toBe('193.0 km');
    expect(formatDistance(1_500, 'metric')).toBe('1.5 km');
  });

  it('formats imperial (mi, 1 decimal) from meters', () => {
    expect(formatDistance(1609.344, 'imperial')).toBe('1.0 mi');
    // 120 miles
    expect(formatDistance(120 * 1609.344, 'imperial')).toBe('120.0 mi');
  });

  it('defaults to metric when unitSystem is omitted', () => {
    expect(formatDistance(1000)).toBe('1.0 km');
  });

  it('always shows the unit label, even for 0', () => {
    expect(formatDistance(0, 'metric')).toBe('0.0 km');
    expect(formatDistance(0, 'imperial')).toBe('0.0 mi');
  });

  it('handles negative and very large values', () => {
    expect(formatDistance(-1000, 'metric')).toBe('-1.0 km');
    expect(formatDistance(1_000_000_000, 'metric')).toBe('1,000,000.0 km');
  });

  it('returns N/A for null/undefined/NaN', () => {
    expect(formatDistance(null)).toBe('N/A');
    expect(formatDistance(undefined)).toBe('N/A');
    expect(formatDistance(NaN)).toBe('N/A');
  });
});

describe('parseDistance', () => {
  it('converts metric km-entry to meters', () => {
    expect(parseDistance(193, 'metric')).toBeCloseTo(193_000, 5);
  });

  it('converts imperial mile-entry to meters', () => {
    expect(parseDistance(120, 'imperial')).toBeCloseTo(120 * 1609.344, 5);
  });

  it('returns null for invalid input', () => {
    expect(parseDistance(null, 'metric')).toBeNull();
    expect(parseDistance(undefined, 'metric')).toBeNull();
    expect(parseDistance(NaN, 'metric')).toBeNull();
  });

  it('round-trips through formatDistance within 1-decimal rounding tolerance', () => {
    for (const unitSystem of ['metric', 'imperial'] as const) {
      for (const meters of [0, 1_500, 193_000, 1_000_000]) {
        const displayed = formatDistance(meters, unitSystem);
        const displayedNumber = Number(displayed.split(' ')[0]!.replace(/,/g, ''));
        const roundTripped = parseDistance(displayedNumber, unitSystem)!;
        // Tolerance = half the smallest representable display unit (0.05 in
        // display units) converted back to meters.
        const toleranceMeters = unitSystem === 'imperial' ? 0.05 * 1609.344 : 0.05 * 1000;
        expect(Math.abs(roundTripped - meters)).toBeLessThanOrEqual(toleranceMeters + 1e-6);
      }
    }
  });
});

describe('formatSpeed', () => {
  it('formats metric (km/h, 0 decimals)', () => {
    expect(formatSpeed(100, 'metric')).toBe('100 km/h');
  });

  it('formats imperial (mph, 0 decimals) with rounding', () => {
    expect(formatSpeed(100, 'imperial')).toBe('62 mph');
  });

  it('returns N/A for invalid input', () => {
    expect(formatSpeed(undefined)).toBe('N/A');
  });

  it('handles 0 and negative values', () => {
    expect(formatSpeed(0, 'metric')).toBe('0 km/h');
    expect(formatSpeed(-10, 'metric')).toBe('-10 km/h');
  });
});

describe('parseSpeed', () => {
  it('converts imperial mph-entry to km/h', () => {
    expect(parseSpeed(62, 'imperial')).toBeCloseTo(62 * 1.609344, 5);
  });

  it('is identity for metric', () => {
    expect(parseSpeed(100, 'metric')).toBe(100);
  });

  it('returns null for invalid input', () => {
    expect(parseSpeed(null, 'metric')).toBeNull();
  });
});

describe('formatTemperature', () => {
  it('formats metric (°C) and imperial (°F)', () => {
    expect(formatTemperature(0, 'metric')).toBe('0 °C');
    expect(formatTemperature(0, 'imperial')).toBe('32 °F');
    expect(formatTemperature(37, 'imperial')).toBe('99 °F');
  });

  it('handles negative Celsius correctly (meaningful for temperature)', () => {
    expect(formatTemperature(-40, 'metric')).toBe('-40 °C');
    expect(formatTemperature(-40, 'imperial')).toBe('-40 °F');
  });

  it('returns N/A for invalid input', () => {
    expect(formatTemperature(null)).toBe('N/A');
  });
});

describe('parseTemperature', () => {
  it('converts Fahrenheit-entry back to Celsius', () => {
    expect(parseTemperature(32, 'imperial')).toBeCloseTo(0, 5);
    expect(parseTemperature(212, 'imperial')).toBeCloseTo(100, 5);
  });

  it('is identity for metric', () => {
    expect(parseTemperature(37, 'metric')).toBe(37);
  });

  it('returns null for invalid input', () => {
    expect(parseTemperature(null, 'imperial')).toBeNull();
    expect(parseTemperature(undefined, 'metric')).toBeNull();
  });

  it('round-trips within 0-decimal rounding tolerance', () => {
    for (const c of [-40, 0, 37, 100]) {
      const displayed = formatTemperature(c, 'imperial');
      const displayedNumber = Number(displayed.split(' ')[0]);
      const roundTripped = parseTemperature(displayedNumber, 'imperial')!;
      expect(Math.abs(roundTripped - c)).toBeLessThanOrEqual(0.5 * (5 / 9) + 1e-9);
    }
  });
});

describe('formatVolume', () => {
  it('formats metric (L) and imperial (gal), 1 decimal', () => {
    expect(formatVolume(200, 'metric')).toBe('200.0 L');
    expect(formatVolume(200, 'imperial')).toBe('52.8 gal');
  });

  it('returns N/A for invalid input', () => {
    expect(formatVolume(undefined)).toBe('N/A');
  });
});

describe('parseVolume', () => {
  it('converts gallon-entry back to liters', () => {
    expect(parseVolume(52.8, 'imperial')).toBeCloseTo(52.8 * 3.785411784, 3);
  });

  it('is identity for metric', () => {
    expect(parseVolume(200, 'metric')).toBe(200);
  });

  it('returns null for invalid input', () => {
    expect(parseVolume(NaN, 'metric')).toBeNull();
  });
});

describe('formatWeight', () => {
  it('formats metric (kg) and imperial (lb), 0 decimals', () => {
    expect(formatWeight(2000, 'metric')).toBe('2,000 kg');
    expect(formatWeight(2000, 'imperial')).toBe('4,409 lb');
  });

  it('returns N/A for invalid input', () => {
    expect(formatWeight(null)).toBe('N/A');
  });
});

describe('parseWeight', () => {
  it('converts pound-entry back to kilograms', () => {
    expect(parseWeight(4409, 'imperial')).toBeCloseTo(4409 / 2.20462262, 2);
  });

  it('is identity for metric', () => {
    expect(parseWeight(2000, 'metric')).toBe(2000);
  });

  it('returns null for invalid input', () => {
    expect(parseWeight(undefined, 'metric')).toBeNull();
  });
});

describe('unit label always visible', () => {
  it('every format* function appends a unit suffix, never a bare number', () => {
    expect(formatDistance(1000, 'metric')).toMatch(/km$/);
    expect(formatDistance(1000, 'imperial')).toMatch(/mi$/);
    expect(formatSpeed(10, 'metric')).toMatch(/km\/h$/);
    expect(formatSpeed(10, 'imperial')).toMatch(/mph$/);
    expect(formatTemperature(10, 'metric')).toMatch(/°C$/);
    expect(formatTemperature(10, 'imperial')).toMatch(/°F$/);
    expect(formatVolume(10, 'metric')).toMatch(/L$/);
    expect(formatVolume(10, 'imperial')).toMatch(/gal$/);
    expect(formatWeight(10, 'metric')).toMatch(/kg$/);
    expect(formatWeight(10, 'imperial')).toMatch(/lb$/);
  });
});
