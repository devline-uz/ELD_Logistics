import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { useForm } from 'react-hook-form';
import { describe, expect, it } from 'vitest';

import '@/app/i18n';
import { FormDateRangePicker } from './FormDateRangePicker';

interface Values {
  period: { start: Date | null; end: Date | null };
}

function Harness() {
  const { control } = useForm<Values>({
    defaultValues: { period: { start: null, end: null } },
  });
  return <FormDateRangePicker name="period" control={control} label="Period" />;
}

describe('FormDateRangePicker', () => {
  it('opens the range picker dialog when the trigger is activated', async () => {
    render(<Harness />);
    const trigger = screen.getByRole('button', { name: /period/i });
    await userEvent.click(trigger);
    expect(screen.getByRole('dialog')).toBeInTheDocument();
  });
});
