import { useState } from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it } from 'vitest';

import '@/app/i18n';
import { Modal } from '@/components/ui/Modal';

function TestHarness() {
  const [open, setOpen] = useState(false);
  return (
    <div>
      <button
        type="button"
        onClick={() => {
          setOpen(true);
        }}
      >
        Open modal
      </button>
      <Modal
        open={open}
        onClose={() => {
          setOpen(false);
        }}
        title="Unit 101"
        footer={<button type="button">Save</button>}
      >
        <input aria-label="First field" />
        <input aria-label="Second field" />
      </Modal>
    </div>
  );
}

describe('Modal', () => {
  it('does not render when closed', () => {
    render(
      <Modal open={false} onClose={() => undefined} title="Hidden">
        content
      </Modal>,
    );
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
  });

  it('renders as an accessible dialog with a labelled title', () => {
    render(
      <Modal open onClose={() => undefined} title="Unit 101">
        Body content
      </Modal>,
    );
    const dialog = screen.getByRole('dialog');
    expect(dialog).toHaveAttribute('aria-modal', 'true');
    expect(dialog).toHaveAccessibleName('Unit 101');
    expect(screen.getByText('Body content')).toBeInTheDocument();
  });

  it('moves focus into the dialog and restores it to the trigger on close', async () => {
    const user = userEvent.setup();
    render(<TestHarness />);

    const openButton = screen.getByRole('button', { name: 'Open modal' });
    openButton.focus();
    await user.click(openButton);

    const firstField = await screen.findByRole('textbox', { name: 'First field' });
    expect(firstField).toHaveFocus();

    await user.keyboard('{Escape}');

    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
    expect(openButton).toHaveFocus();
  });

  it('traps Tab navigation inside the dialog', async () => {
    const user = userEvent.setup();
    render(<TestHarness />);

    await user.click(screen.getByRole('button', { name: 'Open modal' }));

    const first = screen.getByRole('textbox', { name: 'First field' });
    const second = screen.getByRole('textbox', { name: 'Second field' });
    const save = screen.getByRole('button', { name: 'Save' });
    const close = screen.getByRole('button', { name: /close/i });

    expect(first).toHaveFocus();
    await user.tab();
    expect(second).toHaveFocus();
    await user.tab();
    expect(save).toHaveFocus();
    await user.tab();
    expect(close).toHaveFocus();
    await user.tab();
    expect(first).toHaveFocus();

    await user.tab({ shift: true });
    expect(close).toHaveFocus();
  });

  it('closes on backdrop click but not on content click', async () => {
    const user = userEvent.setup();
    let open = true;
    const onClose = () => {
      open = false;
    };
    const { rerender } = render(
      <Modal open={open} onClose={onClose} title="Unit 101">
        <button type="button">Inside</button>
      </Modal>,
    );

    await user.click(screen.getByRole('button', { name: 'Inside' }));
    expect(open).toBe(true);

    await user.click(screen.getByRole('dialog').parentElement!);
    expect(open).toBe(false);
    rerender(
      <Modal open={open} onClose={onClose} title="Unit 101">
        <button type="button">Inside</button>
      </Modal>,
    );
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
  });
});
