import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { useForm } from 'react-hook-form';
import { describe, expect, it } from 'vitest';

import { FormSelect } from './FormSelect';

interface Values {
  status: string;
}

function Harness() {
  const { control } = useForm<Values>({ defaultValues: { status: '' } });
  return (
    <FormSelect
      name="status"
      control={control}
      label="Status"
      options={[
        { value: 'active', label: 'Active' },
        { value: 'inactive', label: 'Inactive' },
      ]}
    />
  );
}

describe('FormSelect', () => {
  it('opens the listbox and updates the form value on selection', async () => {
    render(<Harness />);

    const combobox = screen.getByRole('combobox');
    await userEvent.click(combobox);
    await userEvent.click(screen.getByRole('option', { name: 'Active' }));

    expect(screen.getByDisplayValue('Active')).toBeInTheDocument();
  });
});
