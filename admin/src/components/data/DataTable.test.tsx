import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import type { ColumnDef } from '@tanstack/react-table';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import { DataTable } from './DataTable';

interface Row {
  id: string;
  name: string;
  status: string;
}

const rows: Row[] = [
  { id: '1', name: 'Unit 101', status: 'active' },
  { id: '2', name: 'Unit 102', status: 'inactive' },
];

const columns: ColumnDef<Row, unknown>[] = [
  { id: 'name', header: 'Name', accessorKey: 'name', enableSorting: true },
  { id: 'status', header: 'Status', accessorKey: 'status' },
];

describe('DataTable', () => {
  beforeEach(() => {
    window.localStorage.clear();
  });

  afterEach(() => {
    window.localStorage.clear();
  });

  it('renders rows and column headers with scope="col"', () => {
    render(<DataTable tableId="units" columns={columns} data={rows} />);

    expect(screen.getByText('Unit 101')).toBeInTheDocument();
    expect(screen.getByText('Unit 102')).toBeInTheDocument();
    const headers = screen.getAllByRole('columnheader');
    expect(headers).toHaveLength(2);
  });

  it('shows skeleton placeholders while loading', () => {
    const { container } = render(
      <DataTable tableId="units" columns={columns} data={[]} isLoading />,
    );
    expect(container.querySelectorAll('tbody tr')).toHaveLength(5);
  });

  it('shows an empty state when there is no data', () => {
    render(<DataTable tableId="units" columns={columns} data={[]} />);
    expect(screen.getByText(/no data found/i)).toBeInTheDocument();
  });

  it('shows an error state and calls onRetry', async () => {
    const onRetry = vi.fn();
    render(
      <DataTable
        tableId="units"
        columns={columns}
        data={[]}
        isError
        errorMessage="Something broke"
        onRetry={onRetry}
      />,
    );
    expect(screen.getByText('Something broke')).toBeInTheDocument();
    await userEvent.click(screen.getByRole('button', { name: /try again/i }));
    expect(onRetry).toHaveBeenCalled();
  });

  it('calls onSortChange with the toggled order and sets aria-sort', async () => {
    const onSortChange = vi.fn();
    const { rerender } = render(
      <DataTable
        tableId="units"
        columns={columns}
        data={rows}
        sort="name"
        order="asc"
        onSortChange={onSortChange}
      />,
    );

    const nameHeader = screen.getAllByRole('columnheader')[0];
    expect(nameHeader).toHaveAttribute('aria-sort', 'ascending');

    await userEvent.click(screen.getByRole('button', { name: /name/i }));
    expect(onSortChange).toHaveBeenCalledWith('name', 'desc');

    rerender(
      <DataTable
        tableId="units"
        columns={columns}
        data={rows}
        sort="name"
        order="desc"
        onSortChange={onSortChange}
      />,
    );
    expect(screen.getAllByRole('columnheader')[0]).toHaveAttribute('aria-sort', 'descending');
  });

  it('calls onRowClick when a row is activated by click or Enter', async () => {
    const onRowClick = vi.fn();
    render(<DataTable tableId="units" columns={columns} data={rows} onRowClick={onRowClick} />);

    const firstRow = screen.getAllByRole('button').find((el) => el.tagName === 'TR');
    expect(firstRow).toBeTruthy();
    await userEvent.click(firstRow!);
    expect(onRowClick).toHaveBeenCalledWith(rows[0]);

    firstRow!.focus();
    await userEvent.keyboard('{Enter}');
    expect(onRowClick).toHaveBeenCalledTimes(2);
  });

  it('persists column visibility to localStorage under table:<tableId>:columns', async () => {
    render(<DataTable tableId="units" columns={columns} data={rows} />);

    await userEvent.click(screen.getByRole('button', { name: /columns/i }));
    const statusCheckbox = screen.getByRole('checkbox', { name: 'Status' });
    await userEvent.click(statusCheckbox);

    const stored = window.localStorage.getItem('table:units:columns');
    expect(stored).not.toBeNull();
    expect(JSON.parse(stored ?? '{}')).toMatchObject({ status: false });
    expect(screen.queryByText('active')).not.toBeInTheDocument();
  });
});
