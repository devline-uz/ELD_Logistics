/**
 * `onCompanyChanged` / `setCompanyId` — D54 tenant almashtirish hodisasi
 * (`docs/tz/16-17-registry-open-questions.md`).
 */
import { afterEach, describe, expect, it, vi } from 'vitest';

import { getCompanyId, onCompanyChanged, setCompanyId } from '@/api/session';
import { useAuthStore } from '@/store/auth-store';

afterEach(() => {
  useAuthStore.getState().reset();
});

describe('onCompanyChanged', () => {
  it('tenant o‘zgarganda tinglovchini yangi id bilan chaqiradi', () => {
    const listener = vi.fn();
    const unsubscribe = onCompanyChanged(listener);

    setCompanyId('company-1');

    expect(listener).toHaveBeenCalledWith('company-1');
    expect(getCompanyId()).toBe('company-1');

    unsubscribe();
  });

  it('bir xil qiymat qayta o‘rnatilsa tinglovchi chaqirilmaydi', () => {
    setCompanyId('company-1');
    const listener = vi.fn();
    const unsubscribe = onCompanyChanged(listener);

    setCompanyId('company-1');

    expect(listener).not.toHaveBeenCalled();
    unsubscribe();
  });

  it('impersonatsiyadan chiqishda (`null`) ham tinglovchi chaqiriladi', () => {
    setCompanyId('company-1');
    const listener = vi.fn();
    const unsubscribe = onCompanyChanged(listener);

    setCompanyId(null);

    expect(listener).toHaveBeenCalledWith(null);
    expect(getCompanyId()).toBeNull();
    unsubscribe();
  });

  it('unsubscribe qilingandan keyin tinglovchi chaqirilmaydi', () => {
    const listener = vi.fn();
    const unsubscribe = onCompanyChanged(listener);
    unsubscribe();

    setCompanyId('company-2');

    expect(listener).not.toHaveBeenCalled();
  });
});
