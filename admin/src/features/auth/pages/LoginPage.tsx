import { zodResolver } from '@hookform/resolvers/zod';
import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';

import { login } from '@/api/auth.api';
import { applyTokens } from '@/api/refresh';
import { AuthLayout } from '@/app/layouts/AuthLayout';
import { resolveDeviceId } from '@/features/auth/device-id';
import { loginSchema, type LoginFormValues } from '@/features/auth/schemas';
import { Alert } from '@/components/feedback/Alert';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { useRetryAfter } from '@/features/auth/useRetryAfter';
import { isApiError } from '@/lib/errors';
import { useToast } from '@/components/feedback/toast-context';

const SESSION_END_MESSAGES: Record<string, string> = {
  session_expired: 'errors.sessionExpired',
  idle_timeout: 'idle.description',
};

/** `/login` — TZ §7.1.1. */
export function LoginPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const toast = useToast();
  const [searchParams] = useSearchParams();
  const { secondsLeft, start: startRetryCountdown } = useRetryAfter();
  const [formError, setFormError] = useState<string | null>(null);

  const reasonKey = searchParams.get('reason');
  const sessionEndMessage = reasonKey ? SESSION_END_MESSAGES[reasonKey] : undefined;

  const {
    register,
    handleSubmit,
    watch,
    formState: { errors, isSubmitting },
  } = useForm<LoginFormValues>({
    resolver: zodResolver(loginSchema),
    defaultValues: { identifier: '', password: '', remember: false },
    mode: 'onBlur',
  });

  const [showPassword, setShowPassword] = useState(false);
  const remember = watch('remember');

  const onSubmit = handleSubmit(async (values) => {
    setFormError(null);

    try {
      const result = await login({
        username: values.identifier,
        password: values.password,
        device_type: 'web',
        device_id: resolveDeviceId(remember),
      });

      if (result.requires_totp_setup) {
        applyTokens(
          {
            access_token: result.access_token,
            expires_in: result.expires_in,
            refresh_token: result.refresh_token,
            token_type: result.token_type,
          },
          { sessionId: result.session_id, limited: true },
        );
        void navigate('/2fa/setup', { replace: true });
        return;
      }

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

      if (result.replaced_session) {
        toast.show({ variant: 'warning', message: t('toast.replacedSession') });
      }

      void navigate('/', { replace: true });
    } catch (error) {
      if (isApiError(error)) {
        if (error.status === 429) {
          setFormError(t('auth.login.errors.rateLimited'));
          startRetryCountdown(error.retryAfterSeconds ?? 60);
          return;
        }
        if (error.code === 'ACCOUNT_INACTIVE') {
          setFormError(t('auth.login.errors.accountInactive'));
          return;
        }
        if (error.fields.totp_code) {
          // 2FA allaqachon yoqilgan — kod kiritish ekraniga o'tiladi
          // (`TwoFactorVerifyPage` izohi: D-f10).
          void navigate('/2fa/verify', {
            state: {
              pendingLogin: {
                username: values.identifier,
                password: values.password,
                device_type: 'web',
                device_id: resolveDeviceId(remember),
              },
            },
          });
          return;
        }
        // Kirish xatosi maydonga bog'lanmaydi — qaysi maydon noto'g'ri
        // ekanini oshkor qilmaslik uchun (fe-screens §7.1.1).
        setFormError(t('auth.login.errors.invalidCredentials'));
        return;
      }
      setFormError(t('errors.unknown'));
    }
  });

  const retryBlocked = secondsLeft > 0;

  return (
    <AuthLayout>
      <h1 className="mb-6 text-xl font-semibold text-neutral-900">{t('pages.login.title')}</h1>

      <form
        className="flex flex-col gap-4"
        noValidate
        onSubmit={(event) => {
          void onSubmit(event);
        }}
      >
        {sessionEndMessage ? <Alert message={t(sessionEndMessage)} variant="info" /> : null}
        {formError ? <Alert message={formError} /> : null}

        <Input
          autoComplete="username"
          error={errors.identifier?.message}
          label={t('auth.login.fields.identifier')}
          required
          {...register('identifier')}
        />

        <Input
          autoComplete="current-password"
          error={errors.password?.message}
          label={t('auth.login.fields.password')}
          required
          suffix={
            <button
              aria-label={
                showPassword ? t('auth.login.hidePassword') : t('auth.login.showPassword')
              }
              className="text-xs underline"
              onClick={() => {
                setShowPassword((value) => !value);
              }}
              type="button"
            >
              {showPassword ? t('auth.login.hidePassword') : t('auth.login.showPassword')}
            </button>
          }
          type={showPassword ? 'text' : 'password'}
          {...register('password')}
        />

        <label className="flex items-center gap-2 text-sm text-neutral-700">
          <input type="checkbox" {...register('remember')} />
          {t('auth.login.fields.remember')}
        </label>

        <Button disabled={retryBlocked || undefined} fullWidth loading={isSubmitting} type="submit">
          {retryBlocked
            ? t('auth.login.retryIn', { seconds: secondsLeft })
            : t('auth.login.submit')}
        </Button>

        <Link className="text-center text-sm underline" to="/forgot-password">
          {t('auth.login.forgotPassword')}
        </Link>
      </form>
    </AuthLayout>
  );
}

export default LoginPage;
