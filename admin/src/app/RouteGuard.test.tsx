import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { describe, expect, it } from 'vitest';

import '@/app/i18n';
import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { RouteGuard } from '@/app/RouteGuard';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { PERM } from '@/lib/permissions';

function renderWithPermissions(ui: React.ReactNode, permissions: string[]) {
  return render(
    <MemoryRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
      <PermissionsProvider permissions={permissions}>{ui}</PermissionsProvider>
    </MemoryRouter>,
  );
}

describe('RouteGuard', () => {
  it('renders the page when the permission is granted', () => {
    renderWithPermissions(
      <RouteGuard permission={PERM.unitsRead}>
        <p>unit list</p>
      </RouteGuard>,
      [PERM.unitsRead],
    );

    expect(screen.getByText('unit list')).toBeInTheDocument();
  });

  it('shows the 403 screen (not a redirect, not 404) on direct URL entry', () => {
    renderWithPermissions(
      <RouteGuard permission={PERM.unitsRead}>
        <p>unit list</p>
      </RouteGuard>,
      [],
    );

    expect(screen.queryByText('unit list')).not.toBeInTheDocument();
    expect(screen.getByText('You do not have permission to view this page')).toBeInTheDocument();
    expect(screen.queryByText('Not found')).not.toBeInTheDocument();
  });
});

describe('PermissionGate', () => {
  it('removes the child from the DOM when the permission is missing', () => {
    renderWithPermissions(
      <PermissionGate permission={PERM.unitsCreate}>
        <button type="button">Add Unit</button>
      </PermissionGate>,
      [PERM.unitsRead],
    );

    expect(screen.queryByRole('button', { name: 'Add Unit' })).not.toBeInTheDocument();
  });

  it('honours anyOf and allOf', () => {
    renderWithPermissions(
      <>
        <PermissionGate anyOf={[PERM.unitsCreate, PERM.unitsRead]}>
          <span>any ok</span>
        </PermissionGate>
        <PermissionGate allOf={[PERM.unitsRead, PERM.unitsCreate]}>
          <span>all ok</span>
        </PermissionGate>
      </>,
      [PERM.unitsRead],
    );

    expect(screen.getByText('any ok')).toBeInTheDocument();
    expect(screen.queryByText('all ok')).not.toBeInTheDocument();
  });
});
