import { act, renderHook } from '@testing-library/react';
import type { ReactNode } from 'react';
import { MemoryRouter } from 'react-router-dom';
import { describe, expect, it } from 'vitest';

import { useListParams } from '@/hooks/useListParams';

function wrapper(initialEntries: string[]) {
  return function Wrapper({ children }: { children: ReactNode }) {
    return <MemoryRouter initialEntries={initialEntries}>{children}</MemoryRouter>;
  };
}

describe('useListParams', () => {
  it('defaults page=1 and per_page=25 when URL is empty', () => {
    const { result } = renderHook(() => useListParams(), { wrapper: wrapper(['/units']) });
    expect(result.current.page).toBe(1);
    expect(result.current.perPage).toBe(25);
    expect(result.current.search).toBe('');
    expect(result.current.hasActiveFilters).toBe(false);
  });

  it('rejects an invalid per_page value and falls back to default', () => {
    const { result } = renderHook(() => useListParams(), {
      wrapper: wrapper(['/units?per_page=999']),
    });
    expect(result.current.perPage).toBe(25);
  });

  it('reads sort/order/search/filters from the URL', () => {
    const { result } = renderHook(() => useListParams(), {
      wrapper: wrapper(['/units?sort=unit_number&order=desc&search=101&status=active']),
    });
    expect(result.current.sort).toBe('unit_number');
    expect(result.current.order).toBe('desc');
    expect(result.current.search).toBe('101');
    expect(result.current.filters).toEqual({ status: 'active' });
    expect(result.current.hasActiveFilters).toBe(true);
  });

  it('resets page to 1 when search changes', () => {
    const { result } = renderHook(() => useListParams(), {
      wrapper: wrapper(['/units?page=3']),
    });
    expect(result.current.page).toBe(3);

    act(() => result.current.setSearch('foo'));
    expect(result.current.page).toBe(1);
    expect(result.current.search).toBe('foo');
  });

  it('resets page to 1 when a filter changes', () => {
    const { result } = renderHook(() => useListParams(), {
      wrapper: wrapper(['/units?page=2']),
    });

    act(() => result.current.setFilter('status', 'active'));
    expect(result.current.page).toBe(1);
    expect(result.current.filters).toEqual({ status: 'active' });

    act(() => result.current.setFilter('status', undefined));
    expect(result.current.filters).toEqual({});
  });

  it('clearFilters removes search and all non-reserved params, keeps sort', () => {
    const { result } = renderHook(() => useListParams(), {
      wrapper: wrapper(['/units?sort=unit_number&order=asc&search=x&status=active&make=Ford']),
    });

    act(() => result.current.clearFilters());
    expect(result.current.search).toBe('');
    expect(result.current.filters).toEqual({});
    expect(result.current.sort).toBe('unit_number');
  });

  it('setPerPage clamps to allowed values and resets page', () => {
    const { result } = renderHook(() => useListParams(), {
      wrapper: wrapper(['/units?page=4']),
    });

    act(() => result.current.setPerPage(50));
    expect(result.current.perPage).toBe(50);
    expect(result.current.page).toBe(1);
  });

  it('throws when a reserved key is used as a filter', () => {
    const { result } = renderHook(() => useListParams(), { wrapper: wrapper(['/units']) });
    expect(() => result.current.setFilter('sort', 'x')).toThrow();
  });
});
