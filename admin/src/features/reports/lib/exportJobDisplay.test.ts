import { describe, expect, it } from 'vitest';
import type { TFunction } from 'i18next';

import { formatExportJobFileSize, summarizeExportParams } from './exportJobDisplay';

/** Testda faqat kalitni qaytaradigan yengil `t()` stub — tarjima matnini emas, kalit
 * yo'lini tekshiramiz (fe-testing: haqiqiy i18next yuklamasdan pure funksiyani sinash). */
const t = ((key: string, options?: { count?: number }) =>
  options?.count !== undefined ? `${key}:${options.count}` : key) as unknown as TFunction;

describe('formatExportJobFileSize', () => {
  it("bayt/KB/MB oralig'ini to'g'ri formatlaydi", () => {
    expect(formatExportJobFileSize(500)).toBe('500 B');
    expect(formatExportJobFileSize(20_480)).toBe('20.0 KB');
    expect(formatExportJobFileSize(5 * 1024 * 1024)).toBe('5.0 MB');
  });

  it("noma'lum qiymatda N/A qaytaradi", () => {
    expect(formatExportJobFileSize(undefined)).toBe('N/A');
    expect(formatExportJobFileSize(null)).toBe('N/A');
    expect(formatExportJobFileSize(-1)).toBe('N/A');
  });
});

describe('summarizeExportParams', () => {
  it('quarter/year/mode/comment ni bitta qatorga birlashtiradi', () => {
    const summary = summarizeExportParams(
      { quarter: 3, year: 2026, mode: 'regions_and_units', comment: 'Q3 run' },
      t,
    );
    expect(summary).toBe(
      'Q3 2026 · reports.distanceByRegion.generateModal.modeOptions.regions_and_units · Q3 run',
    );
  });

  it("from/to va driver_ids sonini ko'rsatadi (ism berilmagan bo'lsa)", () => {
    const summary = summarizeExportParams(
      { from: '2026-09-01', to: '2026-09-08', driver_ids: ['a', 'b'] },
      t,
    );
    expect(summary).toBe('2026-09-01 – 2026-09-08 · reports.exportJobs.params.driverCount:2');
  });

  it("driverNames berilsa ismlarni ko'rsatadi, sonini emas", () => {
    const summary = summarizeExportParams({ driver_ids: ['a'] }, t, { driverNames: ['John Doe'] });
    expect(summary).toBe('John Doe');
  });

  it("params bo'sh bo'lsa N/A qaytaradi", () => {
    expect(summarizeExportParams(undefined, t)).toBe('N/A');
    expect(summarizeExportParams({}, t)).toBe('N/A');
  });
});
