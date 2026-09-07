import { act, renderHook } from '@testing-library/react';
import { afterEach, describe, expect, it } from 'vitest';

import { useDateFormat } from '@/hooks/useDateFormat';
import { DEFAULT_COMPANY_CONTEXT, useCompanyStore } from '@/store/company-store';

afterEach(() => {
  act(() => {
    useCompanyStore.setState({ company: DEFAULT_COMPANY_CONTEXT });
  });
});

describe('useDateFormat', () => {
  it('formats using the default company context (UTC, generic)', () => {
    const { result } = renderHook(() => useDateFormat());
    expect(result.current.timezone).toBe('UTC');
    expect(result.current.regulationProfile).toBe('generic');
    expect(result.current.formatDate('2025-12-17T14:05:00Z')).toBe('17/12/2025');
    expect(result.current.formatTime('2025-12-17T14:05:00Z')).toBe('14:05');
  });

  it('re-renders with the us_fmcsa pattern when the company store changes', () => {
    const { result } = renderHook(() => useDateFormat());

    act(() => {
      useCompanyStore.getState().setCompany({ regulationProfile: 'us_fmcsa', timezone: 'UTC' });
    });

    expect(result.current.formatDate('2025-12-17T14:05:00Z')).toBe('12/17/2025');
    expect(result.current.formatTime('2025-12-17T14:05:00Z')).toBe('02:05 PM');
    expect(result.current.formatDateTime('2025-12-17T14:05:00Z')).toBe('12/17/2025 02:05 PM');
  });

  it('exposes formatWeekday, formatDateRange and formatDuration', () => {
    const { result } = renderHook(() => useDateFormat());
    expect(result.current.formatWeekday('2025-12-17T14:05:00Z')).toBe('Wed');
    expect(result.current.formatDateWithWeekday('2025-12-17T14:05:00Z')).toBe('Wed, 17/12/2025');
    expect(result.current.formatTimezoneAbbreviation('2025-12-17T14:05:00Z')).toBe('UTC');
    expect(result.current.formatDateRange('2025-12-17T00:00:00Z', '2025-12-20T00:00:00Z')).toBe(
      '17/12/2025 – 20/12/2025',
    );
    expect(result.current.formatDuration(65)).toBe('01:05');
    expect(result.current.formatDuration(null)).toBe('N/A');
  });

  it('formatRelative honors an explicit "now" and the company timezone', () => {
    const { result } = renderHook(() => useDateFormat());
    const now = new Date('2025-12-17T14:05:00Z');
    expect(result.current.formatRelative('2025-12-17T14:03:00Z', now)).toBe('2 minutes ago');
  });

  it('returns N/A from date formatters for invalid input', () => {
    const { result } = renderHook(() => useDateFormat());
    expect(result.current.formatDate(null)).toBe('N/A');
    expect(result.current.formatDateTime(undefined)).toBe('N/A');
  });
});
