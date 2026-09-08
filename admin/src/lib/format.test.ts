import { describe, expect, it } from 'vitest';

import {
  NA,
  formatDate,
  formatDateRange,
  formatDateTime,
  formatDateWithWeekday,
  formatDuration,
  formatPersonName,
  formatRelative,
  formatTime,
  formatTimezoneAbbreviation,
  formatWeekday,
  formatCoordinate,
  formatCoordinatePair,
  resolveDateFormatProfile,
  toDateParam,
} from './format';

const GENERIC = { timezone: 'UTC', regulationProfile: 'generic' };
const US = { timezone: 'UTC', regulationProfile: 'us_fmcsa' };

describe('resolveDateFormatProfile', () => {
  it('keeps us_fmcsa as-is', () => {
    expect(resolveDateFormatProfile('us_fmcsa')).toBe('us_fmcsa');
  });

  it('collapses every other profile (generic, canada, texas, ...) to generic', () => {
    expect(resolveDateFormatProfile('generic')).toBe('generic');
    expect(resolveDateFormatProfile('canada')).toBe('generic');
    expect(resolveDateFormatProfile('texas')).toBe('generic');
    expect(resolveDateFormatProfile('california')).toBe('generic');
    expect(resolveDateFormatProfile('alaska')).toBe('generic');
    expect(resolveDateFormatProfile('hawaii')).toBe('generic');
    expect(resolveDateFormatProfile(undefined)).toBe('generic');
    expect(resolveDateFormatProfile('unknown_future_profile')).toBe('generic');
  });
});

describe('defaults from the company store (no options passed)', () => {
  it('formatDate/formatTime/formatDateWithWeekday fall back to the company store context', () => {
    // DEFAULT_COMPANY_CONTEXT: timezone 'UTC', regulationProfile 'generic'.
    expect(formatDate('2025-12-17T14:05:00Z')).toBe('17/12/2025');
    expect(formatTime('2025-12-17T14:05:00Z')).toBe('14:05');
    expect(formatDateWithWeekday('2025-12-17T14:05:00Z')).toBe('Wed, 17/12/2025');
  });
});

describe('formatDate', () => {
  const iso = '2025-12-17T14:05:00Z';

  it('formats DD/MM/YYYY for generic', () => {
    expect(formatDate(iso, GENERIC)).toBe('17/12/2025');
  });

  it('formats MM/DD/YYYY for us_fmcsa', () => {
    expect(formatDate(iso, US)).toBe('12/17/2025');
  });

  it('accepts a bare IsoDate (no time part)', () => {
    expect(formatDate('2025-01-05', GENERIC)).toBe('05/01/2025');
  });

  it.each([null, undefined, '', 'not-a-date', 'invalid-iso-string'])(
    'returns N/A for invalid input: %s',
    (value) => {
      expect(formatDate(value, GENERIC)).toBe(NA);
    },
  );

  it('accepts a native Date instance directly', () => {
    expect(formatDate(new Date('2025-12-17T14:05:00Z'), GENERIC)).toBe('17/12/2025');
  });

  it('returns N/A for an invalid native Date instance', () => {
    expect(formatDate(new Date('not-a-real-date'), GENERIC)).toBe(NA);
  });
});

describe('formatTime', () => {
  const iso = '2025-12-17T14:05:00Z';

  it('formats 24h for generic', () => {
    expect(formatTime(iso, GENERIC)).toBe('14:05');
  });

  it('formats 12h with AM/PM for us_fmcsa', () => {
    expect(formatTime(iso, US)).toBe('02:05 PM');
  });

  it('formats midnight and noon boundaries correctly in us_fmcsa', () => {
    expect(formatTime('2025-12-17T00:00:00Z', US)).toBe('12:00 AM');
    expect(formatTime('2025-12-17T12:00:00Z', US)).toBe('12:00 PM');
  });

  it('returns N/A for invalid input', () => {
    expect(formatTime(undefined, GENERIC)).toBe(NA);
  });
});

describe('formatDateTime', () => {
  const iso = '2025-12-17T14:05:00Z';

  it('combines date + time per profile', () => {
    expect(formatDateTime(iso, GENERIC)).toBe('17/12/2025 14:05');
    expect(formatDateTime(iso, US)).toBe('12/17/2025 02:05 PM');
  });

  it('returns N/A for null', () => {
    expect(formatDateTime(null, GENERIC)).toBe(NA);
  });
});

describe('formatWeekday', () => {
  it('returns a 3-letter abbreviation regardless of profile', () => {
    expect(formatWeekday('2025-12-17T14:05:00Z', GENERIC)).toBe('Wed');
    expect(formatWeekday('2025-12-17T14:05:00Z', US)).toBe('Wed');
    expect(formatWeekday('2025-12-19T00:00:00Z', GENERIC)).toBe('Fri');
  });

  it('returns N/A for invalid input', () => {
    expect(formatWeekday('garbage', GENERIC)).toBe(NA);
  });
});

describe('formatDateWithWeekday', () => {
  it('formats "EEE, <date>" per profile', () => {
    expect(formatDateWithWeekday('2025-12-17T14:05:00Z', GENERIC)).toBe('Wed, 17/12/2025');
    expect(formatDateWithWeekday('2025-12-17T14:05:00Z', US)).toBe('Wed, 12/17/2025');
  });

  it('returns N/A for invalid input', () => {
    expect(formatDateWithWeekday('not-a-date', GENERIC)).toBe(NA);
  });
});

describe('formatTimezoneAbbreviation', () => {
  it('shows the IANA zone abbreviation', () => {
    expect(
      formatTimezoneAbbreviation('2025-12-17T14:05:00Z', { timezone: 'America/Chicago' }),
    ).toBe('CST');
  });

  it('handles a DST-observing zone across the transition boundary', () => {
    // America/Chicago: CDT (summer) -> CST (winter)
    expect(
      formatTimezoneAbbreviation('2025-07-01T14:05:00Z', { timezone: 'America/Chicago' }),
    ).toBe('CDT');
    expect(
      formatTimezoneAbbreviation('2025-12-17T14:05:00Z', { timezone: 'America/Chicago' }),
    ).toBe('CST');
  });

  it('returns N/A for invalid input', () => {
    expect(formatTimezoneAbbreviation(undefined, GENERIC)).toBe(NA);
  });
});

describe('timezone handling', () => {
  it('renders the same instant differently across company timezone vs. a distant zone', () => {
    const iso = '2025-12-17T14:05:00Z';
    expect(formatTime(iso, { timezone: 'UTC', regulationProfile: 'generic' })).toBe('14:05');
    expect(formatTime(iso, { timezone: 'America/Chicago', regulationProfile: 'generic' })).toBe(
      '08:05',
    );
    expect(formatTime(iso, { timezone: 'Asia/Tashkent', regulationProfile: 'generic' })).toBe(
      '19:05',
    );
  });

  it('crosses the date boundary when the company timezone differs from UTC', () => {
    // 2025-12-17T23:30:00Z is already 2025-12-18 in Asia/Tashkent (+05:00)
    expect(
      formatDate('2025-12-17T23:30:00Z', {
        timezone: 'Asia/Tashkent',
        regulationProfile: 'generic',
      }),
    ).toBe('18/12/2025');
  });
});

describe('formatDateRange', () => {
  it('joins two formatted dates with an en dash', () => {
    expect(formatDateRange('2025-12-17T00:00:00Z', '2025-12-20T00:00:00Z', GENERIC)).toBe(
      '17/12/2025 – 20/12/2025',
    );
  });

  it('shows N/A on the side with a missing/invalid date', () => {
    expect(formatDateRange(null, '2025-12-20T00:00:00Z', GENERIC)).toBe('N/A – 20/12/2025');
    expect(formatDateRange('2025-12-17T00:00:00Z', undefined, GENERIC)).toBe('17/12/2025 – N/A');
  });
});

describe('formatDuration', () => {
  it('formats HH:MM from minutes', () => {
    expect(formatDuration(0)).toBe('00:00');
    expect(formatDuration(5)).toBe('00:05');
    expect(formatDuration(65)).toBe('01:05');
  });

  it('does not cap hours at 24', () => {
    expect(formatDuration(30 * 60)).toBe('30:00');
    expect(formatDuration(100 * 60 + 15)).toBe('100:15');
  });

  it('formats negative durations with a leading minus sign', () => {
    expect(formatDuration(-65)).toBe('-01:05');
    expect(formatDuration(-5)).toBe('-00:05');
  });

  it('supports HH:MM:SS via seconds unit', () => {
    expect(formatDuration(3661, { unit: 'seconds', withSeconds: true })).toBe('01:01:01');
    expect(formatDuration(0, { unit: 'seconds', withSeconds: true })).toBe('00:00:00');
    expect(formatDuration(-3661, { unit: 'seconds', withSeconds: true })).toBe('-01:01:01');
  });

  it('rounds the minute up when the leftover seconds are >= 30 (HH:MM mode)', () => {
    expect(formatDuration(1.6)).toBe('00:02'); // 96s -> 1m36s -> rounds to 2m
    expect(formatDuration(1.4)).toBe('00:01'); // 84s -> 1m24s -> stays 1m
  });

  it('returns N/A for null/undefined/NaN/Infinity', () => {
    expect(formatDuration(null)).toBe(NA);
    expect(formatDuration(undefined)).toBe(NA);
    expect(formatDuration(NaN)).toBe(NA);
    expect(formatDuration(Infinity)).toBe(NA);
    expect(formatDuration(-Infinity)).toBe(NA);
  });
});

describe('formatRelative', () => {
  const now = new Date('2025-12-17T14:05:00Z');

  it('returns "just now" for sub-second differences', () => {
    expect(formatRelative('2025-12-17T14:05:00.500Z', { ...GENERIC, now })).toBe('just now');
  });

  it('formats minutes/hours ago within the 24h threshold', () => {
    expect(formatRelative('2025-12-17T14:03:00Z', { ...GENERIC, now })).toBe('2 minutes ago');
    expect(formatRelative('2025-12-17T12:05:00Z', { ...GENERIC, now })).toBe('2 hours ago');
  });

  it('formats future instants with "from now"', () => {
    expect(formatRelative('2025-12-17T14:07:00Z', { ...GENERIC, now })).toBe('2 minutes from now');
  });

  it('falls back to absolute formatDateTime at/after the 24h threshold', () => {
    const twoDaysAgo = '2025-12-15T14:05:00Z';
    expect(formatRelative(twoDaysAgo, { ...GENERIC, now })).toBe(
      formatDateTime(twoDaysAgo, GENERIC),
    );
    expect(formatRelative(twoDaysAgo, { ...US, now })).toBe(formatDateTime(twoDaysAgo, US));
  });

  it('returns N/A for invalid input', () => {
    expect(formatRelative(null, { ...GENERIC, now })).toBe(NA);
  });

  it('defaults "now" to the current time when not provided', () => {
    expect(formatRelative(new Date().toISOString())).toBe('just now');
  });
});

describe('formatCoordinate / formatCoordinatePair', () => {
  it('renders 7 decimal places (F101)', () => {
    expect(formatCoordinate(23.9746455)).toBe('23.9746455');
    expect(formatCoordinatePair(31.52, 74.35)).toBe('31.5200000, 74.3500000');
  });

  it('returns N/A when either side is missing or not finite', () => {
    expect(formatCoordinate(undefined)).toBe(NA);
    expect(formatCoordinatePair(31.52, undefined)).toBe(NA);
    expect(formatCoordinatePair(null, 74.35)).toBe(NA);
    expect(formatCoordinatePair(Number.NaN, 74.35)).toBe(NA);
  });
});

describe('toDateParam', () => {
  it('uses the LOCAL calendar date, not the UTC one', () => {
    // Runner zonasidan qat'i nazar mahalliy kun qaytadi. Eski
    // `toISOString().slice(0,10)` implementatsiyasi ofset noldan farq
    // qilganda kunni siljitardi — quyidagi taqqoslash aynan shuni ushlaydi.
    const evening = new Date(2026, 8, 7, 22, 30, 0);
    expect(toDateParam(evening)).toBe('2026-09-07');

    // Sun'iy ravishda manfiy ofsetli holatni modellashtiramiz: mahalliy
    // 23:30 UTC bo'yicha ertangi kunga tushadigan payt.
    const nearMidnight = new Date(2026, 8, 7, 23, 59, 0);
    expect(toDateParam(nearMidnight)).toBe('2026-09-07');
    if (nearMidnight.getTimezoneOffset() > 0) {
      // UTC-X zonada eski usul boshqa kun berardi.
      expect(nearMidnight.toISOString().slice(0, 10)).not.toBe(toDateParam(nearMidnight));
    }
  });

  it('handles the early-morning boundary in positive-offset zones', () => {
    const earlyMorning = new Date(2026, 0, 1, 0, 15, 0);
    expect(toDateParam(earlyMorning)).toBe('2026-01-01');
  });

  it('pads month and day to two digits', () => {
    expect(toDateParam(new Date(2026, 2, 5, 12, 0, 0))).toBe('2026-03-05');
  });

  it('returns N/A for an invalid date', () => {
    expect(toDateParam(new Date('nope'))).toBe(NA);
  });
});

describe('formatPersonName', () => {
  it('joins first and last name', () => {
    expect(formatPersonName({ first_name: 'John', last_name: 'Doe' })).toBe('John Doe');
  });

  it('tolerates a missing half of the name', () => {
    expect(formatPersonName({ first_name: 'John', last_name: null })).toBe('John');
    expect(formatPersonName({ first_name: undefined, last_name: 'Doe' })).toBe('Doe');
  });

  it('falls back to NA when the person is empty, null or undefined', () => {
    expect(formatPersonName({})).toBe(NA);
    expect(formatPersonName(null)).toBe(NA);
    expect(formatPersonName(undefined)).toBe(NA);
  });

  it('uses the provided fallback instead of NA', () => {
    expect(formatPersonName(null, '')).toBe('');
    expect(formatPersonName({ first_name: '  ', last_name: '  ' }, 'unassigned')).toBe(
      'unassigned',
    );
  });
});
