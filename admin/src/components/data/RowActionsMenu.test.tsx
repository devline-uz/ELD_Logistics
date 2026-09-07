import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';

import '@/app/i18n';
import { RowActionsMenu } from './RowActionsMenu';

describe('RowActionsMenu', () => {
  it('renders nothing when there are no items', () => {
    const { container } = render(<RowActionsMenu items={[]} ariaLabel="Row actions" />);
    expect(container).toBeEmptyDOMElement();
  });

  it('opens the menu and calls onSelect for the clicked item', async () => {
    const onSelect = vi.fn();
    render(
      <RowActionsMenu ariaLabel="Row actions" items={[{ key: 'view', label: 'View', onSelect }]} />,
    );

    await userEvent.click(screen.getByRole('button', { name: 'Row actions' }));
    await userEvent.click(screen.getByRole('menuitem', { name: 'View' }));

    expect(onSelect).toHaveBeenCalledTimes(1);
    expect(screen.queryByRole('menu')).not.toBeInTheDocument();
  });

  it('disables an item and does not call onSelect when clicked', async () => {
    const onSelect = vi.fn();
    render(
      <RowActionsMenu
        ariaLabel="Row actions"
        items={[
          { key: 'edit', label: 'Edit', onSelect, disabled: true, disabledReason: 'No access' },
        ]}
      />,
    );

    await userEvent.click(screen.getByRole('button', { name: 'Row actions' }));
    const item = screen.getByRole('menuitem', { name: 'Edit' });
    expect(item).toBeDisabled();
    await userEvent.click(item);
    expect(onSelect).not.toHaveBeenCalled();
  });

  it('closes the menu on Escape and returns focus to the trigger', async () => {
    render(
      <RowActionsMenu
        ariaLabel="Row actions"
        items={[{ key: 'view', label: 'View', onSelect: vi.fn() }]}
      />,
    );

    const trigger = screen.getByRole('button', { name: 'Row actions' });
    await userEvent.click(trigger);
    expect(screen.getByRole('menu')).toBeInTheDocument();

    await userEvent.keyboard('{Escape}');
    expect(screen.queryByRole('menu')).not.toBeInTheDocument();
    expect(trigger).toHaveFocus();
  });
});
