import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { describe, expect, it } from 'vitest';

import '@/app/i18n';
import { Breadcrumb } from '@/components/ui/Breadcrumb';

describe('Breadcrumb', () => {
  it('renders a nav landmark with links and marks the last item as the current page', () => {
    render(
      <MemoryRouter>
        <Breadcrumb
          items={[
            { label: 'Fleet', href: '/fleet' },
            { label: 'Units', href: '/fleet/units' },
            { label: 'Unit 101' },
          ]}
        />
      </MemoryRouter>,
    );

    const nav = screen.getByRole('navigation');
    expect(nav).toHaveAccessibleName('Breadcrumb');

    expect(screen.getByRole('link', { name: 'Fleet' })).toHaveAttribute('href', '/fleet');
    expect(screen.getByRole('link', { name: 'Units' })).toHaveAttribute('href', '/fleet/units');

    const current = screen.getByText('Unit 101');
    expect(current).toHaveAttribute('aria-current', 'page');
    expect(current.tagName).not.toBe('A');
  });
});
