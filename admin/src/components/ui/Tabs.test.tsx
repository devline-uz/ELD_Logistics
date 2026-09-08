import { useState } from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it } from 'vitest';

import { Tabs, type TabItem } from '@/components/ui/Tabs';

const TABS: TabItem[] = [
  { id: 'active', label: 'Active' },
  { id: 'inactive', label: 'Inactive', disabled: true },
  { id: 'archived', label: 'Archived' },
];

function TestHarness() {
  const [activeId, setActiveId] = useState('active');
  return <Tabs tabs={TABS} activeId={activeId} onChange={setActiveId} ariaLabel="Unit status" />;
}

describe('Tabs', () => {
  it('renders a tablist with the correct aria-selected state', () => {
    render(<TestHarness />);
    const tablist = screen.getByRole('tablist', { name: 'Unit status' });
    expect(tablist).toBeInTheDocument();
    expect(screen.getByRole('tab', { name: 'Active' })).toHaveAttribute('aria-selected', 'true');
    expect(screen.getByRole('tab', { name: 'Archived' })).toHaveAttribute('aria-selected', 'false');
  });

  it('selects a tab on click', async () => {
    const user = userEvent.setup();
    render(<TestHarness />);

    await user.click(screen.getByRole('tab', { name: 'Archived' }));
    expect(screen.getByRole('tab', { name: 'Archived' })).toHaveAttribute('aria-selected', 'true');
  });

  it('navigates with arrow keys and skips disabled tabs', async () => {
    const user = userEvent.setup();
    render(<TestHarness />);

    screen.getByRole('tab', { name: 'Active' }).focus();
    await user.keyboard('{ArrowRight}');

    expect(screen.getByRole('tab', { name: 'Archived' })).toHaveFocus();
    expect(screen.getByRole('tab', { name: 'Archived' })).toHaveAttribute('aria-selected', 'true');

    await user.keyboard('{ArrowLeft}');
    expect(screen.getByRole('tab', { name: 'Active' })).toHaveFocus();
  });
});
