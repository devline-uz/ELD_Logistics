import { act, renderHook } from '@testing-library/react';
import { useForm } from 'react-hook-form';
import { describe, expect, it, vi } from 'vitest';

import { ApiError } from '@/lib/errors';

import { applyServerErrors } from './applyServerErrors';

interface FormValues {
  unit_number: string;
  vin: string;
}

function setup() {
  return renderHook(() => {
    const form = useForm<FormValues>({ defaultValues: { unit_number: '', vin: '' } });
    // `formState` is a proxy that only tracks fields read during render — touch
    // `errors` here so `setError` (called outside render) is reflected.
    void form.formState.errors;
    return form;
  });
}

describe('applyServerErrors', () => {
  it('binds field errors that match form fields and focuses the first one', () => {
    const { result } = setup();
    const setFocusSpy = vi.spyOn(result.current, 'setFocus');

    const error = new ApiError({
      code: 'VALIDATION_ERROR',
      status: 422,
      message: 'validation failed',
      fields: { unit_number: 'required', vin: 'must be 17 characters' },
    });

    let outcome!: ReturnType<typeof applyServerErrors>;
    act(() => {
      outcome = applyServerErrors(result.current, error);
    });

    expect(result.current.formState.errors.unit_number?.message).toBe('required');
    expect(result.current.formState.errors.vin?.message).toBe('must be 17 characters');
    expect(outcome.formMessage).toBeUndefined();
    expect(setFocusSpy).toHaveBeenCalledWith('unit_number');
  });

  it('collects unmatched field names into formMessage without losing them', () => {
    const { result } = setup();

    const error = new ApiError({
      code: 'VALIDATION_ERROR',
      status: 422,
      message: 'validation failed',
      fields: { unknown_field: 'something is wrong' },
    });

    const outcome = applyServerErrors(result.current, error);

    expect(outcome.formMessage).toBe('something is wrong');
  });

  it('falls back to the raw message when there are no field details', () => {
    const { result } = setup();

    const error = new ApiError({
      code: 'CONFLICT',
      status: 409,
      message: 'This record changed.',
      fields: {},
    });

    const outcome = applyServerErrors(result.current, error);

    expect(outcome.formMessage).toBe('This record changed.');
  });

  it('handles non-ApiError values gracefully', () => {
    const { result } = setup();

    const outcome = applyServerErrors(result.current, new Error('network down'));

    expect(outcome.formMessage).toBe('network down');
  });
});
