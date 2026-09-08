import { render, screen } from '@testing-library/react';
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
