/**
 * Permission catalogue — MSW handler'lari (2.1, fe-testing §MSW).
 * `GET /permissions` — `permissions.read` **yoki** `roles.read` (OR istisno).
 */
import { http, HttpResponse } from 'msw';

import type { PermissionModule } from '@/api/types';

import { jsonError, url } from './shared';

export function permissionModulesFixture(): PermissionModule[] {
  return [
    {
      module: 'units',
      label: 'Units',
      permissions: [
        { key: 'units.read', description: 'View units' },
        { key: 'units.create', description: 'Create units' },
        { key: 'units.update', description: 'Update units' },
        { key: 'units.delete', description: 'Delete units' },
        { key: 'units.activate', description: 'Activate units' },
        { key: 'units.deactivate', description: 'Deactivate units' },
        { key: 'units.assign_driver', description: 'Assign driver' },
        { key: 'units.diagnostics', description: 'View diagnostics' },
        { key: 'units.export', description: 'Export units' },
        { key: 'units.import', description: 'Import units' },
      ],
    },
    {
      module: 'drivers',
      label: 'Drivers',
      permissions: [
        { key: 'drivers.read', description: 'View drivers' },
        { key: 'drivers.create', description: 'Create drivers' },
        { key: 'drivers.update', description: 'Update drivers' },
        { key: 'drivers.delete', description: 'Delete drivers' },
        { key: 'drivers.license.view', description: 'Reveal licence number' },
      ],
    },
    {
      module: 'roles',
      label: 'Roles',
      permissions: [
        { key: 'roles.read', description: 'View roles' },
        { key: 'roles.create', description: 'Create roles' },
        { key: 'roles.update', description: 'Update roles' },
        { key: 'roles.delete', description: 'Delete roles' },
      ],
    },
  ];
}

/** `GET /permissions` — muvaffaqiyatli. */
export const permissionsListHandler = http.get(url('/permissions'), () =>
  HttpResponse.json({ data: permissionModulesFixture() }),
);

/** `GET /permissions` — `403` (na `permissions.read`, na `roles.read`). */
export const permissionsListForbiddenHandler = http.get(url('/permissions'), () =>
  jsonError('FORBIDDEN', 'Missing permission permissions.read or roles.read', 403),
);

export const permissionsBaseHandlers = [permissionsListHandler];
