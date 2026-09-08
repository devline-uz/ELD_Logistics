import { act, renderHook } from '@testing-library/react';
import { afterEach, describe, expect, it } from 'vitest';

import { useUnitSystem } from '@/hooks/useUnitSystem';
import { DEFAULT_COMPANY_CONTEXT, useCompanyStore } from '@/store/company-store';

afterEach(() => {
  act(() => {
    useCompanyStore.setState({ company: DEFAULT_COMPANY_CONTEXT });
  });
});

describe('useUnitSystem', () => {
  it('formats using the default (imperial) unit system from the company store', () => {
    const { result } = renderHook(() => useUnitSystem());
    expect(result.current.unitSystem).toBe('imperial');
    expect(result.current.formatDistance(1609.344)).toBe('1.0 mi');
  });

  it('re-renders with metric formatting when the company store changes', () => {
    const { result } = renderHook(() => useUnitSystem());

    act(() => {
      useCompanyStore.getState().setCompany({ unitSystem: 'metric' });
    });

    expect(result.current.unitSystem).toBe('metric');
    expect(result.current.formatDistance(1000)).toBe('1.0 km');
  });

  it('parseDistance round-trips consistently with the active unit system', () => {
    const { result } = renderHook(() => useUnitSystem());
    expect(result.current.parseDistance(1)).toBeCloseTo(1609.344, 5);
    expect(result.current.parseSpeed(10)).toBeCloseTo(16.09344, 4);
    expect(result.current.parseTemperature(32)).toBeCloseTo(0, 5);
    expect(result.current.parseVolume(1)).toBeCloseTo(3.785411784, 5);
    expect(result.current.parseWeight(1)).toBeCloseTo(1 / 2.20462262, 5);
  });

  it('returns null from parse* helpers for invalid input', () => {
    const { result } = renderHook(() => useUnitSystem());
    expect(result.current.parseDistance(null)).toBeNull();
    expect(result.current.parseSpeed(undefined)).toBeNull();
    expect(result.current.parseTemperature(NaN)).toBeNull();
    expect(result.current.parseVolume(null)).toBeNull();
    expect(result.current.parseWeight(undefined)).toBeNull();
  });

  it('formats speed, temperature and weight through the same unit system', () => {
    act(() => {
      useCompanyStore.getState().setCompany({ unitSystem: 'metric' });
    });
    const { result } = renderHook(() => useUnitSystem());
    expect(result.current.formatSpeed(100)).toBe('100 km/h');
    expect(result.current.formatTemperature(0)).toBe('0 °C');
    expect(result.current.formatVolume(200)).toBe('200.0 L');
    expect(result.current.formatWeight(2000)).toBe('2,000 kg');
  });
});
