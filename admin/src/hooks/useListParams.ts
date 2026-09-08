/**
 * Ro'yxat ekranlari uchun yagona haqiqat manbai — URL query-string.
 *
 * fe-api §7: `page`, `per_page` (10|25|50), `sort`, `order`, `search` + har
 * ekranga xos filtrlar shu yerdan o'qiladi/yoziladi. Brauzer orqaga/oldinga
 * tugmasi `useSearchParams` orqali avtomatik ishlaydi (React Router URL holati
 * bilan sinxron).
 *
 * Domenga xos bilim yo'q — bu hook faqat query-string bilan ishlaydi.
 */
import { useCallback, useMemo } from 'react';
import { useSearchParams } from 'react-router-dom';

import { DEFAULT_PER_PAGE, PER_PAGE_OPTIONS, type PerPage, type SortOrder } from '@/api/types';

export interface ListParamsState {
  page: number;
  perPage: PerPage;
  sort?: string;
  order?: SortOrder;
  search: string;
  /** Qolgan barcha filtr parametrlari (status, date range va h.k.). */
  filters: Record<string, string>;
}

export interface UseListParamsResult extends ListParamsState {
  setPage: (page: number) => void;
  setPerPage: (perPage: PerPage) => void;
  setSort: (sort: string | undefined, order?: SortOrder) => void;
  setSearch: (search: string) => void;
  setFilter: (key: string, value: string | undefined) => void;
  setFilters: (values: Record<string, string | undefined>) => void;
  clearFilters: () => void;
  /** `search` + boshqa filtrlardan qat'i nazar faol filtr borligini bildiradi. */
  hasActiveFilters: boolean;
}

/** Ushbu kalitlar "umumiy" hisoblanadi — `filters` ro'yxatiga kirmaydi. */
const RESERVED_KEYS = new Set(['page', 'per_page', 'sort', 'order', 'search']);

function parsePerPage(raw: string | null): PerPage {
  const value = Number(raw);
  return (PER_PAGE_OPTIONS as readonly number[]).includes(value)
    ? (value as PerPage)
    : DEFAULT_PER_PAGE;
}

function parsePage(raw: string | null): number {
  const value = Number(raw);
  return Number.isInteger(value) && value > 0 ? value : 1;
}

/**
 * URL query-string'ni ro'yxat ekrani holatiga aylantiradi va uni yangilash
 * uchun setter'lar beradi. Filtr o'zgarsa (`setFilter`/`setFilters`/`setSearch`)
 * `page` avtomatik 1 ga qaytadi.
 */
export function useListParams(): UseListParamsResult {
  const [searchParams, setSearchParams] = useSearchParams();

  const state = useMemo<ListParamsState>(() => {
    const filters: Record<string, string> = {};
    for (const [key, value] of searchParams.entries()) {
      if (!RESERVED_KEYS.has(key)) filters[key] = value;
    }

    const sort = searchParams.get('sort') ?? undefined;
    const orderRaw = searchParams.get('order');
    const order: SortOrder | undefined =
      orderRaw === 'asc' || orderRaw === 'desc' ? orderRaw : undefined;

    return {
      page: parsePage(searchParams.get('page')),
      perPage: parsePerPage(searchParams.get('per_page')),
      sort,
      order,
      search: searchParams.get('search') ?? '',
      filters,
    };
  }, [searchParams]);

  const update = useCallback(
    (mutate: (params: URLSearchParams) => void) => {
      setSearchParams(
        (prev) => {
          const next = new URLSearchParams(prev);
          mutate(next);
          return next;
        },
        { replace: true },
      );
    },
    [setSearchParams],
  );

  const setPage = useCallback(
    (page: number) => {
      update((params) => {
        if (page <= 1) params.delete('page');
        else params.set('page', String(page));
      });
    },
    [update],
  );

  const setPerPage = useCallback(
    (perPage: PerPage) => {
      update((params) => {
        if (perPage === DEFAULT_PER_PAGE) params.delete('per_page');
        else params.set('per_page', String(perPage));
        params.delete('page');
      });
    },
    [update],
  );

  const setSort = useCallback(
    (sort: string | undefined, order: SortOrder = 'asc') => {
      update((params) => {
        if (!sort) {
          params.delete('sort');
          params.delete('order');
        } else {
          params.set('sort', sort);
          params.set('order', order);
        }
      });
    },
    [update],
  );

  const setSearch = useCallback(
    (search: string) => {
      update((params) => {
        if (!search) params.delete('search');
        else params.set('search', search);
        params.delete('page');
      });
    },
    [update],
  );

  const setFilter = useCallback(
    (key: string, value: string | undefined) => {
      if (RESERVED_KEYS.has(key)) {
        throw new Error(`"${key}" is a reserved list param and cannot be used as a filter key`);
      }
      update((params) => {
        if (value === undefined || value === '') params.delete(key);
        else params.set(key, value);
        params.delete('page');
      });
    },
    [update],
  );

  const setFilters = useCallback(
    (values: Record<string, string | undefined>) => {
      update((params) => {
        for (const [key, value] of Object.entries(values)) {
          if (RESERVED_KEYS.has(key)) {
            throw new Error(`"${key}" is a reserved list param and cannot be used as a filter key`);
          }
          if (value === undefined || value === '') params.delete(key);
          else params.set(key, value);
        }
        params.delete('page');
      });
    },
    [update],
  );

  const clearFilters = useCallback(() => {
    update((params) => {
      for (const key of Array.from(params.keys())) {
        if (!RESERVED_KEYS.has(key)) params.delete(key);
      }
      params.delete('search');
      params.delete('page');
    });
  }, [update]);

  const hasActiveFilters = state.search.length > 0 || Object.keys(state.filters).length > 0;

  return {
    ...state,
    setPage,
    setPerPage,
    setSort,
    setSearch,
    setFilter,
    setFilters,
    clearFilters,
    hasActiveFilters,
  };
}
