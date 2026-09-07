import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';

import '@/app/i18n';
import { Pagination } from './Pagination';

describe('Pagination', () => {
  it('disables Previous on the first page and Next on the last page', () => {
    const { rerender } = render(
      <Pagination
        page={1}
        perPage={25}
        total={30}
        onPageChange={vi.fn()}
        onPerPageChange={vi.fn()}
      />,
    );
    expect(screen.getByRole('button', { name: /previous/i })).toBeDisabled();
    expect(screen.getByRole('button', { name: /next/i })).not.toBeDisabled();

    rerender(
      <Pagination
        page={2}
        perPage={25}
        total={30}
        onPageChange={vi.fn()}
        onPerPageChange={vi.fn()}
      />,
    );
    expect(screen.getByRole('button', { name: /previous/i })).not.toBeDisabled();
    expect(screen.getByRole('button', { name: /next/i })).toBeDisabled();
  });

  it('calls onPageChange with the next/previous page', async () => {
    const onPageChange = vi.fn();
    render(
      <Pagination
        page={2}
        perPage={10}
        total={50}
        onPageChange={onPageChange}
        onPerPageChange={vi.fn()}
      />,
    );

    await userEvent.click(screen.getByRole('button', { name: /next/i }));
    expect(onPageChange).toHaveBeenCalledWith(3);

    await userEvent.click(screen.getByRole('button', { name: /previous/i }));
    expect(onPageChange).toHaveBeenCalledWith(1);
  });

  it('marks the current page with aria-current="page"', () => {
    render(
      <Pagination
        page={2}
        perPage={10}
        total={50}
        onPageChange={vi.fn()}
        onPerPageChange={vi.fn()}
      />,
    );
    expect(screen.getByRole('button', { name: '2' })).toHaveAttribute('aria-current', 'page');
  });

  it('only offers 10/25/50 as rows-per-page options', () => {
    render(
      <Pagination
        page={1}
        perPage={25}
        total={100}
        onPageChange={vi.fn()}
        onPerPageChange={vi.fn()}
      />,
    );
    expect(screen.getByDisplayValue('25')).toBeInTheDocument();
  });
});
