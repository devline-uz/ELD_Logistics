import { act, render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import '@/app/i18n';
import { Breadcrumbs } from '@/components/layout/Breadcrumbs';
import { useCompanyStore } from '@/store/company-store';

function renderBreadcrumbs(pathname: string) {
  return render(
    <MemoryRouter
      initialEntries={[pathname]}
      future={{ v7_startTransition: true, v7_relativeSplatPath: true }}
    >
      <Breadcrumbs />
    </MemoryRouter>,
  );
}

describe('Breadcrumbs', () => {
  afterEach(() => {
    act(() => {
      useCompanyStore.getState().resetCompany();
    });
  });

  it("/ da hech narsa ko'rsatmaydi", () => {
    const { container } = renderBreadcrumbs('/');
    expect(container).toBeEmptyDOMElement();
  });

  describe("D32 — regulation_profile bo'yicha oxirgi bo'g'in nomi", () => {
    it('Distance by Region: generic profilda statik nom', () => {
      useCompanyStore.getState().setCompany({ regulationProfile: 'generic' });
      renderBreadcrumbs('/reports/distance-by-region');

      expect(screen.getByText('Distance by Region')).toBeInTheDocument();
    });

    it('Distance by Region: us_fmcsa profilda "IFTA Report"ga almashadi', () => {
      useCompanyStore.getState().setCompany({ regulationProfile: 'us_fmcsa' });
      renderBreadcrumbs('/reports/distance-by-region');

      expect(screen.getByText('IFTA Report')).toBeInTheDocument();
      expect(screen.queryByText('Distance by Region')).not.toBeInTheDocument();
    });

    it('Regulator Export: us_fmcsa profilda "FMCSA Report"ga almashadi', () => {
      useCompanyStore.getState().setCompany({ regulationProfile: 'us_fmcsa' });
      renderBreadcrumbs('/reports/regulator');

      expect(screen.getByText('FMCSA Report')).toBeInTheDocument();
    });
  });
});
