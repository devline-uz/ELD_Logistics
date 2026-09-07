import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import { FiltersBar, type FilterDef } from './FiltersBar';

const filters: FilterDef[] = [
  {
    key: 'status',
    label: 'Status',
    options: [
      { value: 'active', label: 'Active' },
      { value: 'inactive', label: 'Inactive' },
    ],
  },
];

describe('FiltersBar', () => {
  beforeEach(() => {
    vi.useFakeTimers({ shouldAdvanceTime: true });
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('debounces search input by 400ms before calling onSearchChange', async () => {
    const user = userEvent.setup({ advanceTimers: vi.advanceTimersByTime });
    const onSearchChange = vi.fn();
    render(
      <FiltersBar
        search=""
        onSearchChange={onSearchChange}
        activeFilters={{}}
        onFilterChange={vi.fn()}
        onClearAll={vi.fn()}
      />,
    );

    const input = screen.getByRole('textbox');
    await user.type(input, 'foo');
    expect(onSearchChange).not.toHaveBeenCalled();

    vi.advanceTimersByTime(400);
    expect(onSearchChange).toHaveBeenCalledWith('foo');
  });

  it('renders a badge for each active filter and removes it individually', async () => {
    vi.useRealTimers();
    const onFilterChange = vi.fn();
    render(
      <FiltersBar
        search=""
        onSearchChange={vi.fn()}
        filters={filters}
        activeFilters={{ status: 'active' }}
        onFilterChange={onFilterChange}
        onClearAll={vi.fn()}
      />,
    );

    expect(screen.getByText(/Status: Active/)).toBeInTheDocument();
    await userEvent.click(screen.getByRole('button', { name: /remove.*status/i }));
    expect(onFilterChange).toHaveBeenCalledWith('status', undefined);
  });

  it('shows Clear all only when there is an active search or filter, and clears everything', async () => {
    vi.useRealTimers();
    const onClearAll = vi.fn();
    const { rerender } = render(
      <FiltersBar
        search=""
        onSearchChange={vi.fn()}
        activeFilters={{}}
        onFilterChange={vi.fn()}
        onClearAll={onClearAll}
      />,
    );
    expect(screen.queryByRole('button', { name: /clear all/i })).not.toBeInTheDocument();

    rerender(
      <FiltersBar
        search="foo"
        onSearchChange={vi.fn()}
        activeFilters={{}}
        onFilterChange={vi.fn()}
        onClearAll={onClearAll}
      />,
    );
    const clearAll = screen.getByRole('button', { name: /clear all/i });
    await userEvent.click(clearAll);
    expect(onClearAll).toHaveBeenCalled();
  });
});
