import { zodResolver } from '@hookform/resolvers/zod';
import { useMemo } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { Navigate, useLocation, useNavigate } from 'react-router-dom';

import { login } from '@/api/auth.api';
import { applyTokens } from '@/api/refresh';
import { loadSessionContext } from '@/app/bootstrap';
import { AuthLayout } from '@/app/layouts/AuthLayout';
import { Alert } from '@/components/feedback/Alert';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { buildTotpVerifySchema, type TotpVerifyFormValues } from '@/features/auth/schemas';
import { isApiError } from '@/lib/errors';
import type { LoginRequest } from '@/api/types';

export interface TwoFactorVerifyLocationState {
  /** `/login` dan uzatiladi — TOTP kodi bilan login qayta yuboriladi. */
  pendingLogin: LoginRequest;
}

function isPendingLoginState(value: unknown): value is TwoFactorVerifyLocationState {
  return (
    typeof value === 'object' &&
    value !== null &&
    'pendingLogin' in value &&
    typeof (value as { pendingLogin?: unknown }).pendingLogin === 'object'
  );
}

/**
 * `/2fa/verify` — TZ §7.1.2.
 *
 * ⚠️ Spec farqi: `POST /auth/login` javobida faqat `requires_totp_setup`
 * bayrog'i bor (birinchi marta yoqish). Allaqachon yoqilgan 2FA hisobida
 * login `LoginRequest.totp_code` maydonini talab qiladi — backend buni
 * `VALIDATION_ERROR` (`details: [{field: "totp_code"}]`) bilan bildiradi.
 * Shu sababli bu ekran alohida endpoint chaqirmaydi: `/login` dan kelgan
 * login so'rovini **kod bilan qayta yuboradi** (`docs/tz/16-17-registry-
 * open-questions.md` → D-f10 — spec bu oqimni aniq hujjatlashtirmagan).
 */
export function TwoFactorVerifyPage() {
  const { t } = useTranslation();
  const schema = useMemo(() => buildTotpVerifySchema(t), [t]);
  const navigate = useNavigate();
  const location = useLocation();
  const state = location.state as unknown;

  const {
    register,
    handleSubmit,
    setError,
    formState: { errors, isSubmitting },
  } = useForm<TotpVerifyFormValues>({
    resolver: zodResolver(schema),
    defaultValues: { code: '' },
    mode: 'onBlur',
  });

  if (!isPendingLoginState(state)) {
    // To'g'ridan-to'g'ri URL kiritilgan — bu ekran mustaqil holda ishlay
    // olmaydi, login oqimiga qaytariladi.
    return <Navigate replace to="/login" />;
  }

  const { pendingLogin } = state;

  const onSubmit = handleSubmit(async (values) => {
    try {
      const result = await login({ ...pendingLogin, totp_code: values.code });

      applyTokens(
        {
          access_token: result.access_token,
          expires_in: result.expires_in,
          refresh_token: result.refresh_token,
          token_type: result.token_type,
        },
        {
          sessionId: result.session_id,
          limited: false,
          subscriptionReadonly: result.subscription_readonly ?? false,
          replacedSession: result.replaced_session ?? false,
        },
      );

      // Login bilan bir xil sabab (D49): sessiya ochilgach profil/ruxsatlar
      // navigatsiyadan oldin yuklanishi kerak.
      const session = await loadSessionContext().catch(() => null);
      if (session === null || !session.authenticated) {
        setError('code', { message: t('auth.twoFactorVerify.invalidCode') });
        return;
      }

      void navigate('/', { replace: true });
    } catch (error) {
      if (isApiError(error) && error.fields.totp_code) {
        setError('code', { message: error.fields.totp_code });
        return;
      }
      setError('code', { message: t('auth.twoFactorVerify.invalidCode') });
    }
  });

  return (
    <AuthLayout>
      <h1 className="mb-2 text-xl font-semibold text-neutral-900">
        {t('pages.twoFactorVerify.title')}
      </h1>
      <p className="mb-6 text-sm text-neutral-600">{t('auth.twoFactorVerify.description')}</p>

      <form
        className="flex flex-col gap-4"
        noValidate
        onSubmit={(event) => {
          void onSubmit(event);
        }}
      >
        {errors.root?.message ? <Alert message={errors.root.message} /> : null}

        <Input
          autoComplete="one-time-code"
          error={errors.code?.message}
          inputMode="numeric"
          label={t('auth.twoFactorVerify.codeLabel')}
          maxLength={6}
          required
          {...register('code')}
        />

        <Button fullWidth loading={isSubmitting} type="submit">
          {t('auth.twoFactorVerify.submit')}
        </Button>
      </form>
    </AuthLayout>
  );
}

export default TwoFactorVerifyPage;
