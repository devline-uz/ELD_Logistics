import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';

import { ListScreen } from './ListScreen';

describe('ListScreen', () => {
  it('renders the title as an h1 and forwards the table/pagination slots', () => {
    render(
      <ListScreen
        title="Units"
        table={<div data-testid="table">table</div>}
        pagination={<div data-testid="pagination">pagination</div>}
      />,
    );

    expect(screen.getByRole('heading', { level: 1, name: 'Units' })).toBeInTheDocument();
    expect(screen.getByTestId('table')).toBeInTheDocument();
    expect(screen.getByTestId('pagination')).toBeInTheDocument();
  });

  it('renders tabs with correct ARIA roles and calls onTabChange', async () => {
    const onTabChange = vi.fn();
    render(
      <ListScreen
        title="Units"
        tabs={[
          { key: 'active', label: 'Active' },
          { key: 'inactive', label: 'Inactive' },
        ]}
        activeTab="active"
        onTabChange={onTabChange}
        table={<div />}
      />,
    );

    const tablist = screen.getByRole('tablist', { name: 'Units' });
    expect(tablist).toBeInTheDocument();
    const activeTab = screen.getByRole('tab', { name: 'Active' });
    expect(activeTab).toHaveAttribute('aria-selected', 'true');

    await userEvent.click(screen.getByRole('tab', { name: 'Inactive' }));
    expect(onTabChange).toHaveBeenCalledWith('inactive');
  });

  it('renders action buttons and the filters bar slot', () => {
    render(
      <ListScreen
        title="Units"
        actions={<button type="button">Add unit</button>}
        filtersBar={<div data-testid="filters">filters</div>}
        table={<div />}
      />,
    );

    expect(screen.getByRole('button', { name: 'Add unit' })).toBeInTheDocument();
    expect(screen.getByTestId('filters')).toBeInTheDocument();
  });
});
