import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';

import '@/app/i18n';
import { MultiSelect } from './MultiSelect';

const OPTIONS = [
  { value: 'ca', label: 'California' },
  { value: 'tx', label: 'Texas' },
  { value: 'ny', label: 'New York' },
];

describe('MultiSelect', () => {
  it('renders selected values as chips', () => {
    render(
      <MultiSelect label="IFTA States" options={OPTIONS} values={['ca']} onChange={() => {}} />,
    );
    expect(screen.getByText('California')).toBeInTheDocument();
  });

  it('opens the listbox and toggles an option on click', async () => {
    const onChange = vi.fn();
    render(<MultiSelect label="IFTA States" options={OPTIONS} values={[]} onChange={onChange} />);
    await userEvent.click(screen.getByRole('combobox'));
    const listbox = screen.getByRole('listbox');
    expect(listbox).toHaveAttribute('aria-multiselectable', 'true');
    await userEvent.click(screen.getByRole('option', { name: 'Texas' }));
    expect(onChange).toHaveBeenCalledWith(['tx']);
  });

  it('supports "Select all"', async () => {
    const onChange = vi.fn();
    render(
      <MultiSelect
        label="IFTA States"
        options={OPTIONS}
        values={[]}
        onChange={onChange}
        selectAll
      />,
    );
    await userEvent.click(screen.getByRole('combobox'));
    await userEvent.click(screen.getByRole('option', { name: 'Select all' }));
    expect(onChange).toHaveBeenCalledWith(['ca', 'tx', 'ny']);
  });

  it('removes a value when its chip clear button is clicked', async () => {
    const onChange = vi.fn();
    render(
      <MultiSelect
        label="IFTA States"
        options={OPTIONS}
        values={['ca', 'tx']}
        onChange={onChange}
      />,
    );
    await userEvent.click(screen.getByRole('button', { name: 'Clear: California' }));
    expect(onChange).toHaveBeenCalledWith(['tx']);
  });

  it('closes the listbox on Escape', async () => {
    render(<MultiSelect label="IFTA States" options={OPTIONS} values={[]} onChange={() => {}} />);
    const input = screen.getByRole('combobox');
    await userEvent.click(input);
    expect(screen.getByRole('listbox')).toBeInTheDocument();
    await userEvent.keyboard('{Escape}');
    expect(screen.queryByRole('listbox')).not.toBeInTheDocument();
  });

  it('closes the listbox when clicking outside', async () => {
    render(
      <div>
        <button type="button">Outside</button>
        <MultiSelect label="IFTA States" options={OPTIONS} values={[]} onChange={() => {}} />
      </div>,
    );
    await userEvent.click(screen.getByRole('combobox'));
    expect(screen.getByRole('listbox')).toBeInTheDocument();
    await userEvent.click(screen.getByRole('button', { name: 'Outside' }));
    expect(screen.queryByRole('listbox')).not.toBeInTheDocument();
  });

  it('removes an already-selected option when clicked again and toggles off "Select all"', async () => {
    const onChange = vi.fn();
    render(
      <MultiSelect
        label="IFTA States"
        options={OPTIONS}
        values={['ca', 'tx', 'ny']}
        onChange={onChange}
        selectAll
      />,
    );
    await userEvent.click(screen.getByRole('combobox'));
    await userEvent.click(screen.getByRole('option', { name: 'Texas' }));
    expect(onChange).toHaveBeenCalledWith(['ca', 'ny']);
    const selectAllOption = screen.getByRole('option', { name: 'Select all' });
    expect(selectAllOption).toHaveAttribute('aria-selected', 'true');
    await userEvent.click(selectAllOption);
    expect(onChange).toHaveBeenLastCalledWith([]);
  });

  it('navigates options with ArrowDown/ArrowUp and selects with Enter', async () => {
    const onChange = vi.fn();
    render(<MultiSelect label="IFTA States" options={OPTIONS} values={[]} onChange={onChange} />);
    const input = screen.getByRole('combobox');
    await userEvent.click(input);
    await userEvent.keyboard('{ArrowDown}');
    await userEvent.keyboard('{ArrowUp}');
    await userEvent.keyboard('{Enter}');
    expect(onChange).toHaveBeenCalledWith(['ca']);
  });

  it('navigates with ArrowDown from a closed state, which opens the list', async () => {
    render(<MultiSelect label="IFTA States" options={OPTIONS} values={[]} onChange={() => {}} />);
    const input = screen.getByRole('combobox');
    input.focus();
    await userEvent.keyboard('{ArrowDown}');
    expect(screen.getByRole('listbox')).toBeInTheDocument();
  });

  it('removes the last value with Backspace when the query is empty, and Tab closes the list', async () => {
    const onChange = vi.fn();
    render(
      <MultiSelect
        label="IFTA States"
        options={OPTIONS}
        values={['ca', 'tx']}
        onChange={onChange}
      />,
    );
    const input = screen.getByRole('combobox');
    await userEvent.click(input);
    await userEvent.keyboard('{Backspace}');
    expect(onChange).toHaveBeenCalledWith(['ca']);
    await userEvent.keyboard('{Tab}');
    expect(screen.queryByRole('listbox')).not.toBeInTheDocument();
  });

  it('filters options by query when searchable', async () => {
    render(
      <MultiSelect
        label="IFTA States"
        options={OPTIONS}
        values={[]}
        onChange={() => {}}
        searchable
      />,
    );
    const input = screen.getByRole('combobox');
    await userEvent.click(input);
    await userEvent.type(input, 'Tex');
    expect(screen.getByRole('option', { name: 'Texas' })).toBeInTheDocument();
    expect(screen.queryByRole('option', { name: 'California' })).not.toBeInTheDocument();
  });
});
