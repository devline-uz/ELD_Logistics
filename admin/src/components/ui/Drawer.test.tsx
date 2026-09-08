import { useState } from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it } from 'vitest';

import '@/app/i18n';
import { Drawer } from '@/components/ui/Drawer';

function TestHarness() {
  const [open, setOpen] = useState(false);
  return (
    <div>
      <button type="button" onClick={() => setOpen(true)}>
        Track on map
      </button>
      <Drawer open={open} onClose={() => setOpen(false)} title="Unit 101 route">
        <p>Drawer body</p>
      </Drawer>
    </div>
  );
}

describe('Drawer', () => {
  it('does not render when closed', () => {
    render(
      <Drawer open={false} onClose={() => undefined} title="Hidden">
        content
      </Drawer>,
    );
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
  });

  it('renders as a labelled dialog and closes on Escape, restoring focus', async () => {
    const user = userEvent.setup();
    render(<TestHarness />);

    const trigger = screen.getByRole('button', { name: 'Track on map' });
    trigger.focus();
    await user.click(trigger);

    const dialog = await screen.findByRole('dialog');
    expect(dialog).toHaveAccessibleName('Unit 101 route');
    expect(screen.getByText('Drawer body')).toBeInTheDocument();

    await user.keyboard('{Escape}');
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
    expect(trigger).toHaveFocus();
  });

  it('closes via the close button', async () => {
    const user = userEvent.setup();
    render(<TestHarness />);

    await user.click(screen.getByRole('button', { name: 'Track on map' }));
    await user.click(screen.getByRole('button', { name: /close/i }));

    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
  });
});
