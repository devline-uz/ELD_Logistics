import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { PermissionGate } from './PermissionGate';
import { PermissionsContext, type PermissionState } from '@/lib/permissions';

function renderWithPermissions(state: PermissionState, children: React.ReactNode) {
  return render(
    <PermissionsContext.Provider value={state}>{children}</PermissionsContext.Provider>,
  );
}

describe('PermissionGate', () => {
  it('renders children when the single required permission is granted', () => {
    renderWithPermissions(
      { permissions: ['units.read'], isSuperAdmin: false },
      <PermissionGate permission="units.read">
        <button type="button">Edit unit</button>
      </PermissionGate>,
    );
    expect(screen.getByRole('button', { name: 'Edit unit' })).toBeInTheDocument();
  });

  it('renders the fallback when the single required permission is missing', () => {
    renderWithPermissions(
      { permissions: [], isSuperAdmin: false },
      <PermissionGate permission="units.read" fallback={<span>No access</span>}>
        <button type="button">Edit unit</button>
      </PermissionGate>,
    );
    expect(screen.queryByRole('button', { name: 'Edit unit' })).not.toBeInTheDocument();
    expect(screen.getByText('No access')).toBeInTheDocument();
  });

  it('allows access when at least one of "anyOf" is granted', () => {
    renderWithPermissions(
      { permissions: ['units.read'], isSuperAdmin: false },
      <PermissionGate anyOf={['units.read', 'units.update']}>
        <button type="button">Action</button>
      </PermissionGate>,
    );
    expect(screen.getByRole('button', { name: 'Action' })).toBeInTheDocument();
  });

  it('requires every permission in "allOf" to be granted', () => {
    renderWithPermissions(
      { permissions: ['units.read'], isSuperAdmin: false },
      <PermissionGate allOf={['units.read', 'units.update']}>
        <button type="button">Action</button>
      </PermissionGate>,
    );
    expect(screen.queryByRole('button', { name: 'Action' })).not.toBeInTheDocument();
  });

  it('renders nothing by default when access is denied and no fallback is given', () => {
    const { container } = renderWithPermissions(
      { permissions: [], isSuperAdmin: false },
      <PermissionGate permission="units.read">
        <button type="button">Edit unit</button>
      </PermissionGate>,
    );
    expect(container).toBeEmptyDOMElement();
  });
});
