import { act, render, screen } from '@testing-library/react';
import { afterEach, describe, expect, it } from 'vitest';

import '@/app/i18n';
import { SessionFlagsProvider } from '@/app/providers/SessionFlagsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { SubscriptionBanner } from '@/components/layout/SubscriptionBanner';
import { useAuthStore } from '@/store/auth-store';

// Sessiya bayroqlari auth store'da (`session-flags-context.ts`) — bu yerda
// `AppProviders`/`BootstrapGate` o'rniga to'g'ridan-to'g'ri `setState` bilan
// sozlanadi (tarmoq chaqiruvi talab qilmaydi).
function renderBanner() {
  return render(
    <ToastProvider>
      <SessionFlagsProvider>
        <SubscriptionBanner />
      </SessionFlagsProvider>
    </ToastProvider>,
  );
}

afterEach(() => {
  useAuthStore.getState().reset();
});

describe('SubscriptionBanner', () => {
  it('stays hidden while the subscription is active', () => {
    renderBanner();

    expect(screen.queryByRole('status')).not.toBeInTheDocument();
  });

  it('is shown for subscription_readonly sessions', () => {
    act(() => {
      useAuthStore.setState({ subscriptionReadonly: true });
    });
    renderBanner();

    expect(screen.getByRole('status')).toHaveTextContent('Your subscription is read-only');
  });

  it('raises a toast for replaced_session', () => {
    act(() => {
      useAuthStore.setState({ replacedSession: true });
    });
    renderBanner();

    expect(screen.getByText('Another web session was signed out.')).toBeInTheDocument();
  });
});
