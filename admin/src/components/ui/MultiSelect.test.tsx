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
});
