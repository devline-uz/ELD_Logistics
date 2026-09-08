import { act, render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import '@/app/i18n';
import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { MainNav } from '@/components/layout/MainNav';
import { PERM } from '@/lib/permissions';
import { useCompanyStore } from '@/store/company-store';

function renderNav(permissions: string[]) {
  return render(
    <MemoryRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
      <PermissionsProvider permissions={permissions}>
        <MainNav />
      </PermissionsProvider>
    </MemoryRouter>,
  );
}

describe('MainNav', () => {
  it('renders canonical group names and hides groups without permissions', () => {
    renderNav([PERM.unitsRead]);

    expect(screen.getByRole('button', { name: /Fleet Management/ })).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /Fleet Operations/ })).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /Reports/ })).not.toBeInTheDocument();
    expect(screen.queryByRole('link', { name: 'Dashboard' })).not.toBeInTheDocument();
  });

  it('shows only permitted flyout items', async () => {
    const user = userEvent.setup();
    renderNav([PERM.unitsRead, PERM.driversRead]);

    await user.click(screen.getByRole('button', { name: /Fleet Management/ }));

    expect(screen.getByRole('link', { name: /Unit Management/ })).toBeInTheDocument();
    expect(screen.getByRole('link', { name: /Driver Management/ })).toBeInTheDocument();
    expect(screen.queryByRole('link', { name: /Roles & Permissions/ })).not.toBeInTheDocument();
  });

  describe("D32 — regulation_profile bo'yicha Reports flyout nomi", () => {
    afterEach(() => {
      act(() => {
        useCompanyStore.getState().resetCompany();
      });
    });

    it("generic profilda statik nom ko'rsatiladi", async () => {
      useCompanyStore.getState().setCompany({ regulationProfile: 'generic' });
      const user = userEvent.setup();
      renderNav([PERM.reportsRead]);

      await user.click(screen.getByRole('button', { name: /Reports/ }));

      expect(screen.getByRole('link', { name: /Distance by Region/ })).toBeInTheDocument();
      expect(screen.getByRole('link', { name: /Regulator Export/ })).toBeInTheDocument();
    });

    it("us_fmcsa profilda IFTA Report / FMCSA Report ko'rsatiladi", async () => {
      useCompanyStore.getState().setCompany({ regulationProfile: 'us_fmcsa' });
      const user = userEvent.setup();
      renderNav([PERM.reportsRead]);

      await user.click(screen.getByRole('button', { name: /Reports/ }));

      expect(screen.getByRole('link', { name: /IFTA Report/ })).toBeInTheDocument();
      expect(screen.getByRole('link', { name: /FMCSA Report/ })).toBeInTheDocument();
      expect(screen.queryByRole('link', { name: /Distance by Region/ })).not.toBeInTheDocument();
    });
  });
});
