import { describe, expect, it } from 'vitest';

import {
  ALL_PERMISSIONS,
  PERM,
  createPermissionChecker,
  permissionGroupOf,
} from '@/lib/permissions';

describe('createPermissionChecker', () => {
  it('grants only the listed permissions', () => {
    const can = createPermissionChecker({
      permissions: [PERM.unitsRead, PERM.unitsCreate],
      isSuperAdmin: false,
    });

    expect(can(PERM.unitsRead)).toBe(true);
    expect(can(PERM.unitsDelete)).toBe(false);
  });

  it('supports any() and all()', () => {
    const can = createPermissionChecker({
      permissions: [PERM.logsRead],
      isSuperAdmin: false,
    });

    expect(can.any([PERM.logsRead, PERM.violationsRead])).toBe(true);
    expect(can.any([PERM.violationsRead])).toBe(false);
    expect(can.all([PERM.logsRead, PERM.violationsRead])).toBe(false);
    expect(can.all([])).toBe(true);
    expect(can.any([])).toBe(false);
  });

  it('treats super_admin as a flag that only unlocks companies.*', () => {
    const can = createPermissionChecker({ permissions: [], isSuperAdmin: true });

    expect(can.isSuperAdmin).toBe(true);
    expect(can(PERM.companiesRead)).toBe(true);
    expect(can(PERM.unitsRead)).toBe(false);
  });
});

describe('PERM constant', () => {
  it('has no duplicate keys', () => {
    expect(new Set(ALL_PERMISSIONS).size).toBe(ALL_PERMISSIONS.length);
  });

  it('maps keys to their module group', () => {
    expect(permissionGroupOf(PERM.unitsRead)).toBe('units');
    expect(permissionGroupOf(PERM.eldDevicesAssignUnit)).toBe('eld_devices');
    expect(permissionGroupOf(PERM.driversLicenseView)).toBe('drivers');
  });
});
