/**
 * Auth zod sxemalari — validatsiya matnlari i18n kalitlaridan kelishini
 * tekshiradi (TD5: `buildXSchema(t)` fabrikasi naqshi).
 */
import i18n from 'i18next';
import { describe, expect, it } from 'vitest';

import '@/app/i18n';

import {
  buildForgotPasswordSchema,
  buildInvitationAcceptSchema,
  buildLoginSchema,
  buildPasswordSchema,
  buildResetPasswordSchema,
  buildTotpVerifySchema,
} from './schemas';

const t = i18n.t.bind(i18n);

function firstMessage(result: { success: boolean; error?: { issues: { message: string }[] } }) {
  return result.error?.issues[0]?.message;
}

describe('auth schemas', () => {
  it('login: bosh maydonlarda i18n xabari qaytadi', () => {
    const result = buildLoginSchema(t).safeParse({
      identifier: '',
      password: '',
      remember: false,
    });
    expect(result.success).toBe(false);
    expect(firstMessage(result)).toBe(t('auth.validation.identifierRequired'));
  });

  it('parol qoidasi: 10 belgi, harf va raqam', () => {
    const schema = buildPasswordSchema(t);
    expect(firstMessage(schema.safeParse('short'))).toBe(t('auth.validation.passwordMin'));
    expect(firstMessage(schema.safeParse('1234567890'))).toBe(t('auth.validation.passwordLetter'));
    expect(firstMessage(schema.safeParse('abcdefghij'))).toBe(t('auth.validation.passwordNumber'));
    expect(schema.safeParse('abcdefghi1').success).toBe(true);
  });

  it('totp: faqat 6 raqam', () => {
    const schema = buildTotpVerifySchema(t);
    expect(firstMessage(schema.safeParse({ code: '12a4' }))).toBe(t('auth.validation.totpCode'));
    expect(schema.safeParse({ code: '123456' }).success).toBe(true);
  });

  it('forgot password: login majburiy', () => {
    expect(firstMessage(buildForgotPasswordSchema(t).safeParse({ login: '' }))).toBe(
      t('auth.validation.identifierRequired'),
    );
  });

  it('reset/invite: parollar mos kelmasa xabar confirmPassword da', () => {
    for (const build of [buildResetPasswordSchema, buildInvitationAcceptSchema]) {
      const result = build(t).safeParse({
        password: 'abcdefghi1',
        confirmPassword: 'abcdefghi2',
      });
      expect(result.success).toBe(false);
      expect(result.error?.issues[0]?.path).toEqual(['confirmPassword']);
      expect(firstMessage(result)).toBe(t('auth.validation.mismatch'));
    }
  });

  it('xabarlar kalit nomi bo‘lib qolmaydi (kalit topilgan)', () => {
    expect(t('auth.validation.mismatch')).not.toContain('auth.validation');
  });
});
