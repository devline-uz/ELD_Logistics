import { describe, expect, it } from 'vitest';

import { NAV_ENTRIES, filterNav, isNavGroup, navGroupOf, routeTitleKey } from '@/app/nav-config';
import en from '@/locales/en.json';
import { PERM, createPermissionChecker } from '@/lib/permissions';

/** Nuqta bilan ajratilgan kalitni (`nav.fleet.units`) `en.json` ichidan topadi. */
function resolveI18nKey(key: string): unknown {
  return key
    .split('.')
    .reduce<unknown>(
      (node, segment) =>
        node && typeof node === 'object' ? (node as Record<string, unknown>)[segment] : undefined,
      en,
    );
}

/** `NAV_ENTRIES` daraxtidan har bir `labelKey`/`descriptionKey`ni yig'ib chiqadi. */
function collectNavI18nKeys(entries: typeof NAV_ENTRIES): string[] {
  const keys: string[] = [];
  for (const entry of entries) {
    keys.push(entry.labelKey);
    if (isNavGroup(entry)) {
      keys.push(...collectNavI18nKeys(entry.children));
    } else if (entry.descriptionKey) {
      keys.push(entry.descriptionKey);
    }
  }
  return keys;
}

describe('filterNav', () => {
  it('hides everything when the user has no permissions', () => {
    const can = createPermissionChecker({ permissions: [], isSuperAdmin: false });
    expect(filterNav(NAV_ENTRIES, can)).toHaveLength(0);
  });

  it('keeps only permitted leaves and drops emptied groups', () => {
    const can = createPermissionChecker({
      permissions: [PERM.dashboardRead, PERM.unitsRead],
      isSuperAdmin: false,
    });

    const visible = filterNav(NAV_ENTRIES, can);
    expect(visible.map((entry) => entry.id)).toEqual(['dashboard', 'fleet']);

    const fleet = visible.find((entry) => entry.id === 'fleet');
    expect(fleet?.kind).toBe('group');
    if (fleet?.kind === 'group') {
      expect(fleet.children.map((leaf) => leaf.path)).toEqual(['/units']);
    }
  });

  it('shows Violations only with violations.read, not logs.read', () => {
    const can = createPermissionChecker({ permissions: [PERM.logsRead], isSuperAdmin: false });
    const logs = filterNav(NAV_ENTRIES, can).find((entry) => entry.id === 'logs');
    expect(logs?.kind).toBe('group');
    if (logs?.kind === 'group') {
      expect(logs.children.some((leaf) => leaf.path === '/violations')).toBe(false);
    }
  });
});

describe('breadcrumb helpers', () => {
  it('resolves a nav leaf title', () => {
    expect(routeTitleKey('/units')).toBe('nav.fleet.units');
  });

  it('resolves non-nav screens', () => {
    expect(routeTitleKey('/settings/company')).toBe('pages.settingsCompany.title');
  });

  it('finds the owning group, including nested paths', () => {
    expect(navGroupOf('/units/42')?.id).toBe('fleet');
    expect(navGroupOf('/chat')).toBeUndefined();
  });
});

describe('i18n coverage (i18n-keeper)', () => {
  it('resolves every NAV_ENTRIES labelKey/descriptionKey to a real string in en.json', () => {
    const keys = collectNavI18nKeys(NAV_ENTRIES);
    expect(keys.length).toBeGreaterThan(0);
    for (const key of keys) {
      const value = resolveI18nKey(key);
      expect(value, `"${key}" missing from en.json`).toEqual(expect.any(String));
      expect(value).not.toBe('');
    }
  });
});
