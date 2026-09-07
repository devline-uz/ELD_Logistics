import { zodResolver } from '@hookform/resolvers/zod';
import { useEffect, useState } from 'react';
import QRCode from 'qrcode';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';

import { startTotpSetup, verifyTotp } from '@/api/auth.api';
import { applyTokens } from '@/api/refresh';
import { AuthLayout } from '@/app/layouts/AuthLayout';
import { FormAlert } from '@/features/auth/components/FormAlert';
import { FormField } from '@/features/auth/components/FormField';
import { SubmitButton } from '@/features/auth/components/SubmitButton';
import { totpVerifySchema, type TotpVerifyFormValues } from '@/features/auth/schemas';
import { isApiError } from '@/lib/errors';
import type { TotpSetup } from '@/api/types';

/** `/2fa/setup` — TZ §7.1.2. Faqat cheklangan token bilan kirish mumkin. */
export function TwoFactorSetupPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const [setup, setSetup] = useState<TotpSetup | null>(null);
  const [qrDataUrl, setQrDataUrl] = useState<string | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [formError, setFormError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    startTotpSetup()
      .then(async (result) => {
        if (cancelled) return;
        setSetup(result);
        if (result.otpauth_url) {
          const dataUrl = await QRCode.toDataURL(result.otpauth_url);
          if (!cancelled) setQrDataUrl(dataUrl);
        }
      })
      .catch(() => {
        if (!cancelled) setLoadError(t('auth.twoFactorSetup.loadError'));
      });

    return () => {
      cancelled = true;
    };
  }, [t]);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<TotpVerifyFormValues>({
    resolver: zodResolver(totpVerifySchema),
    defaultValues: { code: '' },
    mode: 'onBlur',
  });

  const onSubmit = handleSubmit(async (values) => {
    setFormError(null);
    try {
      const result = await verifyTotp({ code: values.code });
      if (result.tokens) {
        applyTokens(result.tokens, { limited: false });
      }
      void navigate('/', { replace: true });
    } catch (error) {
      if (isApiError(error) && Object.keys(error.fields).length === 0) {
        setFormError(t('auth.twoFactorSetup.invalidCode'));
        return;
      }
      setFormError(t('errors.unknown'));
    }
  });

  return (
    <AuthLayout>
      <h1 className="mb-2 text-xl font-semibold text-neutral-900">
        {t('pages.twoFactorSetup.title')}
      </h1>
      <p className="mb-6 text-sm text-neutral-600">{t('auth.twoFactorSetup.description')}</p>

      {loadError ? <FormAlert message={loadError} /> : null}

      {setup ? (
        <div className="mb-6 flex flex-col items-center gap-3">
          {qrDataUrl ? (
            <img
              alt={t('auth.twoFactorSetup.qrAlt')}
              className="h-40 w-40"
              height={160}
              src={qrDataUrl}
              width={160}
            />
          ) : null}
          {setup.secret ? (
            <p className="text-center text-xs text-neutral-600">
              {t('auth.twoFactorSetup.manualEntry')}{' '}
              <code className="font-mono">{setup.secret}</code>
            </p>
          ) : null}
        </div>
      ) : !loadError ? (
        <p aria-live="polite" className="mb-6 text-sm text-neutral-500" role="status">
          {t('common.states.loading')}
        </p>
      ) : null}

      <form
        className="flex flex-col gap-4"
        noValidate
        onSubmit={(event) => {
          void onSubmit(event);
        }}
      >
        {formError ? <FormAlert message={formError} /> : null}

        <FormField
          autoComplete="one-time-code"
          error={errors.code?.message}
          inputMode="numeric"
          label={t('auth.twoFactorSetup.codeLabel')}
          maxLength={6}
          required
          {...register('code')}
        />

        <SubmitButton loading={isSubmitting}>{t('auth.twoFactorSetup.submit')}</SubmitButton>
      </form>
    </AuthLayout>
  );
}

export default TwoFactorSetupPage;
