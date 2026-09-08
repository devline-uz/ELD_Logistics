import { describe, expect, it } from 'vitest';

import type { TFunction } from 'i18next';

import { buildPasswordChangeSchema, buildTotpCodeSchema } from './schemas';

/** Sxema fabrikalari `t` talab qiladi — testda kalitning o'zi qaytariladi. */
const t = ((key: string) => key) as unknown as TFunction;
const passwordChangeSchema = buildPasswordChangeSchema(t);
const totpCodeSchema = buildTotpCodeSchema(t);

describe('passwordChangeSchema', () => {
  it('joriy parolni majburiy deb talab qiladi (F151/D41)', () => {
    const result = passwordChangeSchema.safeParse({
      currentPassword: '',
      newPassword: 'Str0ngPassphrase',
      confirmPassword: 'Str0ngPassphrase',
    });
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.error.issues.some((issue) => issue.path[0] === 'currentPassword')).toBe(true);
    }
  });

  it('yangi parol va tasdiq mos kelmasa xato beradi', () => {
    const result = passwordChangeSchema.safeParse({
      currentPassword: 'OldPassw0rd',
      newPassword: 'Str0ngPassphrase',
      confirmPassword: 'Different1',
    });
    expect(result.success).toBe(false);
  });

  it("yangi parol joriy parol bilan bir xil bo'lsa xato beradi", () => {
    const result = passwordChangeSchema.safeParse({
      currentPassword: 'Str0ngPassphrase',
      newPassword: 'Str0ngPassphrase',
      confirmPassword: 'Str0ngPassphrase',
    });
    expect(result.success).toBe(false);
  });

  it("to'g'ri qiymatlarda muvaffaqiyatli o'tadi", () => {
    const result = passwordChangeSchema.safeParse({
      currentPassword: 'OldPassw0rd',
      newPassword: 'Str0ngPassphrase',
      confirmPassword: 'Str0ngPassphrase',
    });
    expect(result.success).toBe(true);
  });
});

describe('totpCodeSchema', () => {
  it('6 xonali raqamni talab qiladi', () => {
    expect(totpCodeSchema.safeParse({ code: '123456' }).success).toBe(true);
    expect(totpCodeSchema.safeParse({ code: '12345' }).success).toBe(false);
    expect(totpCodeSchema.safeParse({ code: 'abcdef' }).success).toBe(false);
  });
});
