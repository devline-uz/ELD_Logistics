import { zodResolver } from '@hookform/resolvers/zod';
import { useEffect, useMemo, useState } from 'react';
import QRCode from 'qrcode';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';

import { startTotpSetup, verifyTotp } from '@/api/auth.api';
import { applyTokens } from '@/api/refresh';
import { loadSessionContext } from '@/app/bootstrap';
import { AuthLayout } from '@/app/layouts/AuthLayout';
import { Alert } from '@/components/feedback/Alert';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { buildTotpVerifySchema, type TotpVerifyFormValues } from '@/features/auth/schemas';
import { isApiError } from '@/lib/errors';
import type { TotpSetup } from '@/api/types';

/** `/2fa/setup` — TZ §7.1.2. Faqat cheklangan token bilan kirish mumkin. */
export function TwoFactorSetupPage() {
  const { t } = useTranslation();
  const schema = useMemo(() => buildTotpVerifySchema(t), [t]);
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
    resolver: zodResolver(schema),
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
      // Cheklangan (limited) sessiya to'liq sessiyaga aylandi — ruxsatlar
      // faqat `GET /me` dan keladi, shuning uchun navigatsiyadan oldin
      // profilni yuklaymiz (D49).
      const session = await loadSessionContext().catch(() => null);
      if (session === null) {
        setFormError(t('errors.unknown'));
        return;
      }
      if (!session.authenticated) {
        setFormError(t('errors.sessionExpired'));
        return;
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

      {loadError ? <Alert message={loadError} /> : null}

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
        <p aria-live="polite" className="mb-6 text-sm text-neutral-600" role="status">
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
        {formError ? <Alert message={formError} /> : null}

        <Input
          autoComplete="one-time-code"
          error={errors.code?.message}
          inputMode="numeric"
          label={t('auth.twoFactorSetup.codeLabel')}
          maxLength={6}
          required
          {...register('code')}
        />

        <Button fullWidth loading={isSubmitting} type="submit">
          {t('auth.twoFactorSetup.submit')}
        </Button>
      </form>
    </AuthLayout>
  );
}

export default TwoFactorSetupPage;
