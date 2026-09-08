import { renderHook } from '@testing-library/react';
import type { ReactNode } from 'react';
import { afterEach, describe, expect, it } from 'vitest';

import '@/app/i18n';
import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { useWriteGuard } from '@/hooks/useWriteGuard';
import { PERM } from '@/lib/permissions';
import { useAuthStore } from '@/store/auth-store';

// Sessiya bayroqlari (`subscriptionReadonly`) auth store'da yashaydi
// (`session-flags-context.ts`) — testlar butun provayder daraxtini
// (`AppProviders` → `BootstrapGate`) qurmasdan to'g'ridan-to'g'ri sozlaydi.
function wrapper(permissions: string[], subscriptionReadonly: boolean) {
  useAuthStore.setState({ subscriptionReadonly });
  return function Wrapper({ children }: { children: ReactNode }) {
    return <PermissionsProvider permissions={permissions}>{children}</PermissionsProvider>;
  };
}

afterEach(() => {
  useAuthStore.getState().reset();
});

describe('useWriteGuard', () => {
  it('allows writes with the permission and an active subscription', () => {
    const { result } = renderHook(() => useWriteGuard(), {
      wrapper: wrapper([PERM.unitsCreate], false),
    });

    expect(result.current.canWrite(PERM.unitsCreate)).toBe(true);
    expect(result.current.disabledReason(PERM.unitsCreate)).toBeUndefined();
  });

  it('explains why a button is disabled (F35 — never a reasonless disabled control)', () => {
    const { result } = renderHook(() => useWriteGuard(), {
      wrapper: wrapper([], false),
    });

    expect(result.current.canWrite(PERM.unitsCreate)).toBe(false);
    expect(result.current.disabledReason(PERM.unitsCreate)).toBe(
      'Requires the units.create permission',
    );
  });

  it('blocks every write while the subscription is read-only', () => {
    const { result } = renderHook(() => useWriteGuard(), {
      wrapper: wrapper([PERM.unitsCreate], true),
    });

    expect(result.current.canWrite(PERM.unitsCreate)).toBe(false);
    expect(result.current.disabledReason(PERM.unitsCreate)).toBe('Subscription is read-only');
  });
});
