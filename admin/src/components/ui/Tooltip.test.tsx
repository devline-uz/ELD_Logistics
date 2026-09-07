import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it } from 'vitest';

import { Tooltip } from '@/components/ui/Tooltip';

describe('Tooltip', () => {
  it('is hidden until hovered and links via aria-describedby', async () => {
    const user = userEvent.setup();
    render(
      <Tooltip content="Deletes the unit permanently">
        <button type="button">Delete</button>
      </Tooltip>,
    );

    expect(screen.queryByRole('tooltip')).not.toBeInTheDocument();
    const trigger = screen.getByRole('button', { name: 'Delete' });

    await user.hover(trigger);
    const tooltip = screen.getByRole('tooltip');
    expect(tooltip).toHaveTextContent('Deletes the unit permanently');
    expect(trigger).toHaveAttribute('aria-describedby', tooltip.id);

    await user.unhover(trigger);
    expect(screen.queryByRole('tooltip')).not.toBeInTheDocument();
  });

  it('opens on keyboard focus and closes on Escape', async () => {
    const user = userEvent.setup();
    render(
      <Tooltip content="Extra detail">
        <button type="button">Info</button>
      </Tooltip>,
    );

    await user.tab();
    expect(screen.getByRole('tooltip')).toHaveTextContent('Extra detail');

    await user.keyboard('{Escape}');
    expect(screen.queryByRole('tooltip')).not.toBeInTheDocument();
  });
});
