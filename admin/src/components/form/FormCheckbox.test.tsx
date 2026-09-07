import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { useForm } from 'react-hook-form';
import { describe, expect, it } from 'vitest';

import { FormCheckbox } from './FormCheckbox';

interface Values {
  remember: boolean;
}

function Harness() {
  const { control } = useForm<Values>({ defaultValues: { remember: false } });
  return <FormCheckbox name="remember" control={control} label="Remember this device" />;
}

describe('FormCheckbox', () => {
  it('toggles the form value on click', async () => {
    render(<Harness />);
    const checkbox = screen.getByRole('checkbox', { name: /remember this device/i });
    expect(checkbox).not.toBeChecked();
    await userEvent.click(checkbox);
    expect(checkbox).toBeChecked();
  });
});
