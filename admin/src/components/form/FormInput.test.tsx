import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { describe, expect, it } from 'vitest';

import '@/app/i18n';
import { FormInput } from './FormInput';

interface Values {
  unit_number: string;
}

function Harness({ defaultError }: { defaultError?: string } = {}) {
  const { control, setError } = useForm<Values>({
    defaultValues: { unit_number: '' },
  });

  useEffect(() => {
    if (defaultError) setError('unit_number', { type: 'server', message: defaultError });
  }, [defaultError, setError]);

  return <FormInput name="unit_number" control={control} label="Unit number" required />;
}

describe('FormInput', () => {
  it('renders the label and updates the form value on change', async () => {
    render(<Harness />);
    const input = screen.getByLabelText(/unit number/i);
    await userEvent.type(input, '101');
    expect(input).toHaveValue('101');
  });

  it('shows the required marker', () => {
    render(<Harness />);
    // The visual "*" is aria-hidden; the accessible required state comes from aria-required.
    expect(screen.getByLabelText(/unit number/i)).toHaveAttribute('aria-required', 'true');
  });

  it('shows a validation error message', async () => {
    render(<Harness defaultError="This field is required" />);
    expect(await screen.findByText('This field is required')).toBeInTheDocument();
    expect(screen.getByLabelText(/unit number/i)).toHaveAttribute('aria-invalid', 'true');
  });
});
