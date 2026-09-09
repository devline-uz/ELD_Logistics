import { fireEvent, render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';

import '@/app/i18n';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';

describe('ConfirmDialog', () => {
  it('renders as an alertdialog with the default title', () => {
    render(
      <ConfirmDialog
        open
        onClose={() => undefined}
        onConfirm={() => undefined}
        description="This action cannot be undone. Are you sure you want to delete the unit?"
      />,
    );
    const dialog = screen.getByRole('alertdialog');
    expect(dialog).toHaveAccessibleName('Are you absolutely sure?');
    expect(screen.getByText(/cannot be undone/)).toBeInTheDocument();
  });

  it('confirms without a reason when requireReason is false', async () => {
    const user = userEvent.setup();
    const onConfirm = vi.fn();
    render(
      <ConfirmDialog
        open
        onClose={() => undefined}
        onConfirm={onConfirm}
        description="Delete this record?"
      />,
    );

    await user.click(screen.getByRole('button', { name: 'Confirm' }));
    expect(onConfirm).toHaveBeenCalledWith(undefined);
  });

  it('applies danger styling and blocks confirm until a reason is given', async () => {
    const user = userEvent.setup();
    const onConfirm = vi.fn();
    render(
      <ConfirmDialog
        open
        onClose={() => undefined}
        onConfirm={onConfirm}
        description="Delete this record?"
        variant="danger"
        requireReason
      />,
    );

    await user.click(screen.getByRole('button', { name: 'Confirm' }));
    expect(onConfirm).not.toHaveBeenCalled();
    expect(screen.getByRole('alert')).toHaveTextContent(
      'Please provide a reason before continuing.',
    );

    await user.type(screen.getByLabelText(/Reason/), 'Wrong entry');
    await user.click(screen.getByRole('button', { name: 'Confirm' }));
    expect(onConfirm).toHaveBeenCalledWith('Wrong entry');
  });

  it('rejects a reason shorter than 3 characters', async () => {
    const user = userEvent.setup();
    const onConfirm = vi.fn();
    render(
      <ConfirmDialog
        open
        onClose={() => undefined}
        onConfirm={onConfirm}
        description="Delete this record?"
        requireReason
      />,
    );

    await user.type(screen.getByLabelText(/Reason/), 'ab');
    await user.click(screen.getByRole('button', { name: 'Confirm' }));
    expect(onConfirm).not.toHaveBeenCalled();
    expect(screen.getByRole('alert')).toHaveTextContent(
      'Reason must be between 3 and 500 characters.',
    );
    const textarea = screen.getByLabelText(/Reason/);
    expect(textarea).toHaveAttribute('aria-invalid', 'true');
    expect(textarea).toHaveAttribute('aria-describedby');
  });

  it('accepts a reason of exactly 3 characters', async () => {
    const user = userEvent.setup();
    const onConfirm = vi.fn();
    render(
      <ConfirmDialog
        open
        onClose={() => undefined}
        onConfirm={onConfirm}
        description="Delete this record?"
        requireReason
      />,
    );

    await user.type(screen.getByLabelText(/Reason/), 'abc');
    await user.click(screen.getByRole('button', { name: 'Confirm' }));
    expect(onConfirm).toHaveBeenCalledWith('abc');
  });

  it('accepts a reason of exactly 500 characters', async () => {
    const onConfirm = vi.fn();
    render(
      <ConfirmDialog
        open
        onClose={() => undefined}
        onConfirm={onConfirm}
        description="Delete this record?"
        requireReason
      />,
    );

    const longReason = 'a'.repeat(500);
    const textarea = screen.getByLabelText(/Reason/);
    fireEvent.change(textarea, { target: { value: longReason } });
    await userEvent.click(screen.getByRole('button', { name: 'Confirm' }));
    expect(onConfirm).toHaveBeenCalledWith(longReason);
  });

  it('rejects a reason longer than 500 characters', async () => {
    const onConfirm = vi.fn();
    render(
      <ConfirmDialog
        open
        onClose={() => undefined}
        onConfirm={onConfirm}
        description="Delete this record?"
        requireReason
      />,
    );

    const tooLongReason = 'a'.repeat(501);
    const textarea = screen.getByLabelText(/Reason/);
    fireEvent.change(textarea, { target: { value: tooLongReason } });
    await userEvent.click(screen.getByRole('button', { name: 'Confirm' }));
    expect(onConfirm).not.toHaveBeenCalled();
    expect(screen.getByRole('alert')).toHaveTextContent(
      'Reason must be between 3 and 500 characters.',
    );
  });

  it('rejects a reason that is only whitespace', async () => {
    const user = userEvent.setup();
    const onConfirm = vi.fn();
    render(
      <ConfirmDialog
        open
        onClose={() => undefined}
        onConfirm={onConfirm}
        description="Delete this record?"
        requireReason
      />,
    );

    await user.type(screen.getByLabelText(/Reason/), '   ');
    await user.click(screen.getByRole('button', { name: 'Confirm' }));
    expect(onConfirm).not.toHaveBeenCalled();
    expect(screen.getByRole('alert')).toHaveTextContent(
      'Please provide a reason before continuing.',
    );
  });

  it('calls onClose from the Cancel button', async () => {
    const user = userEvent.setup();
    const onClose = vi.fn();
    render(
      <ConfirmDialog
        open
        onClose={onClose}
        onConfirm={() => undefined}
        description="Deactivate?"
      />,
    );

    await user.click(screen.getByRole('button', { name: 'Cancel' }));
    expect(onClose).toHaveBeenCalled();
  });
});
