import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import '@/app/i18n';
import i18n from '@/app/i18n';
import uiOverlayEn from '@/locales/en/ui-overlay.json';
import { EmptyState } from '@/components/feedback/EmptyState';

i18n.addResourceBundle('en', 'translation', uiOverlayEn, true, true);

describe('EmptyState', () => {
  it('falls back to the default title and description', () => {
    render(<EmptyState />);
    expect(screen.getByText('No Data Found')).toBeInTheDocument();
    expect(screen.getByText('There is no data to show you right now')).toBeInTheDocument();
  });

  it('renders custom title, description and an action', () => {
    render(
      <EmptyState
        title="No results"
        description="No records match your filters"
        action={<button type="button">Clear filters</button>}
      />,
    );
    expect(screen.getByText('No results')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Clear filters' })).toBeInTheDocument();
  });
});
