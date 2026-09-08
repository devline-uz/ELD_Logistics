import { describe, expect, it, vi } from 'vitest';

import i18n, { enResources, mergeLocaleResources, resources } from '@/app/i18n';
import type { LocaleResource } from '@/app/i18n';
import en from '@/locales/en.json';

/** Nuqta bilan ajratilgan kalitni resurs daraxtidan topadi. */
const lookup = (tree: LocaleResource, key: string): unknown =>
  key.split('.').reduce<unknown>((acc, part) => {
    if (typeof acc === 'object' && acc !== null && part in acc) {
      return (acc as Record<string, unknown>)[part];
    }
    return undefined;
  }, tree);

describe('mergeLocaleResources', () => {
  it('deep-merges module branches without dropping base keys', () => {
    const { resources: merged, conflicts } = mergeLocaleResources(
      { common: { save: 'Save' }, nav: { home: 'Home' } },
      { 'realtime.json': { realtime: { title: 'Realtime' }, common: { cancel: 'Cancel' } } },
    );

    expect(merged).toEqual({
      common: { save: 'Save', cancel: 'Cancel' },
      nav: { home: 'Home' },
      realtime: { title: 'Realtime' },
    });
    expect(conflicts).toEqual([]);
  });

  it('returns the base untouched when there are no module files', () => {
    const base = { common: { save: 'Save' } };
    const { resources: merged, conflicts } = mergeLocaleResources(base, {});

    expect(merged).toEqual(base);
    expect(merged).not.toBe(base);
    expect(conflicts).toEqual([]);
  });

  it('does not mutate its inputs', () => {
    const base: LocaleResource = { common: { save: 'Save' } };
    const module: LocaleResource = { common: { cancel: 'Cancel' } };
    mergeLocaleResources(base, { 'a.json': module });

    expect(base).toEqual({ common: { save: 'Save' } });
    expect(module).toEqual({ common: { cancel: 'Cancel' } });
  });

  it('reports full-key collisions between base and module files', () => {
    const { conflicts } = mergeLocaleResources(
      { common: { save: 'Save' } },
      { 'dvir.json': { common: { save: 'Store' } } },
    );

    expect(conflicts).toEqual(['dvir.json: common.save']);
  });

  it('reports collisions between two module files', () => {
    const { conflicts } = mergeLocaleResources(
      {},
      { 'a.json': { dvir: { title: 'A' } }, 'b.json': { dvir: { title: 'B' } } },
    );

    expect(conflicts).toEqual(['b.json: dvir.title']);
  });

  it('reports a leaf/branch type mismatch as a collision', () => {
    const { conflicts, resources: merged } = mergeLocaleResources(
      { dvir: 'Inspections' },
      { 'dvir.json': { dvir: { title: 'Inspections' } } },
    );

    expect(conflicts).toEqual(['dvir.json: dvir']);
    expect(merged).toEqual({ dvir: { title: 'Inspections' } });
  });
});

describe('i18n runtime resources', () => {
  it('exposes the merged tree and keeps every base key resolvable', () => {
    expect(resources.en.translation).toBe(enResources);
    for (const key of Object.keys(en)) {
      expect(lookup(enResources, key)).toBeDefined();
    }
  });

  it('is initialized and translates a base key', () => {
    expect(i18n.isInitialized).toBe(true);
    expect(i18n.t('common.actions.save')).not.toBe('');
  });

  it('has no duplicate keys across en.json and en/*.json', () => {
    const warn = vi.spyOn(console, 'warn');
    const { conflicts } = mergeLocaleResources(en as unknown as LocaleResource, {});
    expect(conflicts).toEqual([]);
    warn.mockRestore();
  });
});
