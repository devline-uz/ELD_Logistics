import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { useForm } from 'react-hook-form';
import { describe, expect, it } from 'vitest';

import { FormTextarea } from './FormTextarea';

interface Values {
  notes: string;
}

function Harness() {
  const { control } = useForm<Values>({ defaultValues: { notes: '' } });
  return <FormTextarea name="notes" control={control} label="Notes" maxLength={60} />;
}

describe('FormTextarea', () => {
  it('updates the form value and shows the remaining character count', async () => {
    render(<Harness />);
    const textarea = screen.getByLabelText(/notes/i);
    await userEvent.type(textarea, 'hello');
    expect(textarea).toHaveValue('hello');
    expect(screen.getByText(/55 characters remaining/i)).toBeInTheDocument();
  });
});
