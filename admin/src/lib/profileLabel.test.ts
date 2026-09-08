import { act, renderHook } from '@testing-library/react';
import { afterEach, describe, expect, it } from 'vitest';

import { useCompanyStore } from '@/store/company-store';

import { resolveProfileLabelBucket, useProfileLabel, useProfileLabelBucket } from './profileLabel';

/** `renderHook` bekor qilinganidan keyin chaqiriladi — `act` bilan o'raladi
 * (RTL cleanup afterEach'dan oldin ishga tushishi mumkin, hali mount holatida). */
afterEach(() => {
  act(() => {
    useCompanyStore.getState().resetCompany();
  });
});

describe('resolveProfileLabelBucket', () => {
  it('us_fmcsa uchun alohida bucket qaytaradi', () => {
    expect(resolveProfileLabelBucket('us_fmcsa')).toBe('us_fmcsa');
  });

  it.each(['generic', 'canada', 'texas', 'california', 'alaska', 'hawaii', undefined])(
    '%s uchun generic bucketga tushadi',
    (profile) => {
      expect(resolveProfileLabelBucket(profile)).toBe('generic');
    },
  );
});

describe('useProfileLabelBucket', () => {
  it('company-store dagi regulationProfile ni bucketga aylantiradi', () => {
    act(() => {
      useCompanyStore.getState().setCompany({ regulationProfile: 'us_fmcsa' });
    });
    const { result } = renderHook(() => useProfileLabelBucket());
    expect(result.current).toBe('us_fmcsa');
  });
});

describe('useProfileLabel', () => {
  it('us_fmcsa profilida .us_fmcsa kalitini qaytaradi', () => {
    act(() => {
      useCompanyStore.getState().setCompany({ regulationProfile: 'us_fmcsa' });
    });
    const { result } = renderHook(() => useProfileLabel('reports.distanceByRegion.screenName'));
    expect(result.current).toBe('IFTA Report');
  });

  it('generic (va boshqa 6 profil) uchun .generic kalitini qaytaradi', () => {
    act(() => {
      useCompanyStore.getState().setCompany({ regulationProfile: 'canada' });
    });
    const { result } = renderHook(() => useProfileLabel('reports.distanceByRegion.screenName'));
    expect(result.current).toBe('Distance by Region');
  });
});
