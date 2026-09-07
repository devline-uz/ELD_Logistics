import { describe, expect, it } from 'vitest';

import {
  ALL_PERMISSIONS,
  PERM,
  PERMISSION_GROUPS,
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

  it('exposes super_admin as a flag that grants no permission key', () => {
    // `super_admin` — permission emas, alohida bayroq (F33): katalogda
    // `companies.*` kaliti yo'q, `/companies*` faqat shu bayroq bilan ochiladi.
    const can = createPermissionChecker({ permissions: [], isSuperAdmin: true });

    expect(can.isSuperAdmin).toBe(true);
    expect(can(PERM.unitsRead)).toBe(false);
    expect(can(PERM.companyRead)).toBe(false);
  });
});

describe('PERM constant', () => {
  it('has no duplicate keys', () => {
    expect(new Set(ALL_PERMISSIONS).size).toBe(ALL_PERMISSIONS.length);
  });

  it('maps keys to their module group', () => {
    expect(permissionGroupOf(PERM.unitsRead)).toBe('units');
    expect(permissionGroupOf(PERM.eldDevicesAssignUnit)).toBe('eld_devices');
    expect(permissionGroupOf(PERM.notificationSettingsUpdate)).toBe('notification_settings');
    // Uch bo'g'inli kalitlar ham o'z guruhiga tushadi.
    expect(permissionGroupOf(PERM.driversLicenseView)).toBe('drivers');
    expect(permissionGroupOf(PERM.companyHistoryView)).toBe('company');
  });

  it('covers every module group', () => {
    expect(new Set(ALL_PERMISSIONS.map(permissionGroupOf))).toEqual(new Set(PERMISSION_GROUPS));
  });
});
