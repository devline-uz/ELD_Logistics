import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import '@/app/i18n';
import { AppProviders } from '@/app/providers';
import { SubscriptionBanner } from '@/components/layout/SubscriptionBanner';

describe('SubscriptionBanner', () => {
  it('stays hidden while the subscription is active', () => {
    render(
      <AppProviders>
        <SubscriptionBanner />
      </AppProviders>,
    );

    expect(screen.queryByRole('status')).not.toBeInTheDocument();
  });

  it('is shown for subscription_readonly sessions', () => {
    render(
      <AppProviders sessionFlags={{ subscriptionReadonly: true }}>
        <SubscriptionBanner />
      </AppProviders>,
    );

    expect(screen.getByRole('status')).toHaveTextContent('Your subscription is read-only');
  });

  it('raises a toast for replaced_session', () => {
    render(
      <AppProviders sessionFlags={{ replacedSession: true }}>
        <SubscriptionBanner />
      </AppProviders>,
    );

    expect(screen.getByText('Another web session was signed out.')).toBeInTheDocument();
  });
});
