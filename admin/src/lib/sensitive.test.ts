import { describe, expect, it } from 'vitest';

import { MASKED_VALUE, isSensitiveField, maskSensitiveValue } from './sensitive';

describe('sensitive', () => {
  it.each([
    'password',
    'password_hash',
    'PasswordHash',
    'totp_secret',
    'refresh_token',
    'api_key',
    'ssn',
    'license_no',
    'licence_number',
    'recovery_code',
  ])('marks %s as sensitive', (field) => {
    expect(isSensitiveField(field)).toBe(true);
  });

  it.each(['name', 'timezone', 'email', 'address', 'unit_number', undefined])(
    'keeps %s non-sensitive',
    (field) => {
      expect(isSensitiveField(field)).toBe(false);
    },
  );

  it('masks the value of a sensitive field', () => {
    expect(maskSensitiveValue('password_hash', '$2a$10$abc')).toBe(MASKED_VALUE);
  });

  it('keeps ordinary values and empty values untouched', () => {
    expect(maskSensitiveValue('name', 'Acme')).toBe('Acme');
    expect(maskSensitiveValue('password', '')).toBe('');
    expect(maskSensitiveValue('password', undefined)).toBeUndefined();
  });
});
