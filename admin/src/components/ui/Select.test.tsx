import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';

import '@/app/i18n';
import { Select } from './Select';

const OPTIONS = [
  { value: 'metric', label: 'Metric' },
  { value: 'imperial', label: 'Imperial' },
  { value: 'generic', label: 'Generic' },
];

describe('Select', () => {
  it('renders a combobox with the selected label', () => {
    render(<Select label="Unit system" options={OPTIONS} value="metric" onChange={() => {}} />);
    expect(screen.getByRole('combobox')).toBeInTheDocument();
    expect(screen.getByDisplayValue('Metric')).toBeInTheDocument();
  });

  it('opens the listbox on click and selects an option', async () => {
    const onChange = vi.fn();
    render(<Select label="Unit system" options={OPTIONS} value={null} onChange={onChange} />);
    await userEvent.click(screen.getByRole('combobox'));
    expect(screen.getByRole('listbox')).toBeInTheDocument();
    await userEvent.click(screen.getByRole('option', { name: 'Imperial' }));
    expect(onChange).toHaveBeenCalledWith('imperial');
  });

  it('supports full keyboard control: ArrowDown, Enter, Escape', async () => {
    const onChange = vi.fn();
    render(<Select label="Unit system" options={OPTIONS} value={null} onChange={onChange} />);
    const input = screen.getByRole('combobox');
    await userEvent.click(input);
    expect(screen.getByRole('listbox')).toBeInTheDocument();
    await userEvent.keyboard('{ArrowDown}');
    await userEvent.keyboard('{Enter}');
    expect(onChange).toHaveBeenCalledWith('imperial');

    await userEvent.keyboard('{ArrowDown}');
    expect(screen.getByRole('listbox')).toBeInTheDocument();
    await userEvent.keyboard('{Escape}');
    expect(screen.queryByRole('listbox')).not.toBeInTheDocument();
  });

  it('marks aria-expanded correctly and clears the value when clearable', async () => {
    const onChange = vi.fn();
    render(
      <Select label="Unit system" options={OPTIONS} value="metric" onChange={onChange} clearable />,
    );
    const combobox = screen.getByRole('combobox');
    expect(combobox).toHaveAttribute('aria-expanded', 'false');
    await userEvent.click(screen.getByRole('button', { name: 'Clear' }));
    expect(onChange).toHaveBeenCalledWith(null);
  });

  it('closes the listbox when clicking outside', async () => {
    render(
      <div>
        <button type="button">Outside</button>
        <Select label="Unit system" options={OPTIONS} value={null} onChange={() => {}} />
      </div>,
    );
    await userEvent.click(screen.getByRole('combobox'));
    expect(screen.getByRole('listbox')).toBeInTheDocument();
    await userEvent.click(screen.getByRole('button', { name: 'Outside' }));
    expect(screen.queryByRole('listbox')).not.toBeInTheDocument();
  });

  it('navigates with ArrowUp and closes with Tab', async () => {
    render(<Select label="Unit system" options={OPTIONS} value={null} onChange={() => {}} />);
    const input = screen.getByRole('combobox');
    await userEvent.click(input);
    await userEvent.keyboard('{ArrowUp}');
    expect(screen.getByRole('listbox')).toBeInTheDocument();
    await userEvent.keyboard('{Tab}');
    expect(screen.queryByRole('listbox')).not.toBeInTheDocument();
  });

  it('skips disabled options when navigating and stays put when all are disabled', async () => {
    const disabledOptions = OPTIONS.map((option) => ({ ...option, disabled: true }));
    render(
      <Select label="Unit system" options={disabledOptions} value={null} onChange={() => {}} />,
    );
    const input = screen.getByRole('combobox');
    await userEvent.click(input);
    await userEvent.keyboard('{ArrowDown}');
    expect(screen.getByRole('option', { name: 'Metric' })).toHaveAttribute('aria-disabled', 'true');
  });

  it('filters options by query when searchable and shows the query as the value', async () => {
    render(
      <Select label="Unit system" options={OPTIONS} value={null} onChange={() => {}} searchable />,
    );
    const input = screen.getByRole('combobox');
    await userEvent.click(input);
    await userEvent.type(input, 'Imp');
    expect(input).toHaveValue('Imp');
    expect(screen.getByRole('option', { name: 'Imperial' })).toBeInTheDocument();
    expect(screen.queryByRole('option', { name: 'Metric' })).not.toBeInTheDocument();
  });

  it('supports type-ahead selection when not searchable', async () => {
    const onChange = vi.fn();
    render(<Select label="Unit system" options={OPTIONS} value={null} onChange={onChange} />);
    const input = screen.getByRole('combobox');
    input.focus();
    await userEvent.keyboard('i');
    await userEvent.keyboard('{Enter}');
    expect(onChange).toHaveBeenCalledWith('imperial');
  });
});
