import type { TFunction } from 'i18next';
import { describe, expect, it } from 'vitest';

import { formatAuditChange } from './changes';

/** Minimal `t` — kalitni interpolyatsiya bilan real `audit.json` matniga aylantiradi. */
const TEXTS: Record<string, string> = {
  'audit.list.changeUpdated': '{{field}} changed from {{oldValue}} to {{newValue}}',
  'audit.list.changeDeleted': 'Deleted {{field}}',
  'audit.list.changeField': 'Changed {{field}}',
  'common.na': 'N/A',
};

const t = ((key: string, vars?: Record<string, string>) =>
  (TEXTS[key] ?? key).replace(
    /\{\{(\w+)\}\}/g,
    (_, name: string) => vars?.[name] ?? '',
  )) as unknown as TFunction;

describe('formatAuditChange', () => {
  it('formats a full diff', () => {
    expect(
      formatAuditChange(t, { field: 'status', old_value: 'new', new_value: 'in_progress' }),
    ).toBe('status changed from new to in_progress');
  });

  it('falls back to N/A for a missing old value (insert)', () => {
    expect(formatAuditChange(t, { field: 'status', old_value: '', new_value: 'new' })).toBe(
      'status changed from N/A to new',
    );
  });

  it('masks sensitive field values (fe-security §5, F206)', () => {
    expect(
      formatAuditChange(t, { field: 'password_hash', old_value: 'abc', new_value: 'def' }),
    ).toBe('password_hash changed from •••••• to ••••••');
  });

  it('returns N/A when there is no field at all (e.g. login/export actions)', () => {
    expect(formatAuditChange(t, { field: undefined })).toBe('N/A');
  });
});
