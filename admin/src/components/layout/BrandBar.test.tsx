import { render, screen } from '@testing-library/react';
import type { ReactNode } from 'react';
import { MemoryRouter } from 'react-router-dom';
import { describe, expect, it } from 'vitest';

import '@/app/i18n';
import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { BrandBar } from '@/components/layout/BrandBar';

function renderBar(slot?: ReactNode) {
  return render(
    <MemoryRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
      <PermissionsProvider permissions={[]}>
        <BrandBar notificationsSlot={slot} />
      </PermissionsProvider>
    </MemoryRouter>,
  );
}

describe('BrandBar', () => {
  it('renders without a notifications slot', () => {
    renderBar();

    expect(screen.getByRole('searchbox')).toBeInTheDocument();
    expect(screen.queryByTestId('notifications-slot')).not.toBeInTheDocument();
  });

  it('renders the injected notifications slot', () => {
    renderBar(<span data-testid="notifications-slot" />);

    expect(screen.getByTestId('notifications-slot')).toBeInTheDocument();
  });
});
