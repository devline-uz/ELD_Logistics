import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { useForm } from 'react-hook-form';
import { describe, expect, it } from 'vitest';

import '@/app/i18n';
import { FormDatePicker } from './FormDatePicker';

interface Values {
  hired_at: Date | null;
}

function Harness() {
  const { control } = useForm<Values>({ defaultValues: { hired_at: null } });
  return <FormDatePicker name="hired_at" control={control} label="Hired at" />;
}

describe('FormDatePicker', () => {
  it('opens the calendar dialog when the trigger is activated', async () => {
    render(<Harness />);
    const trigger = screen.getByRole('button', { name: /hired at/i });
    await userEvent.click(trigger);
    expect(screen.getByRole('dialog')).toBeInTheDocument();
  });
});
