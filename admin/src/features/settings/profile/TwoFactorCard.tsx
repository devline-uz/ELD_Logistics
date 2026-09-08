import { zodResolver } from '@hookform/resolvers/zod';
import { useMemo, useState } from 'react';
import QRCode from 'qrcode';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';

import { useTotpSetupStart, useTotpVerifyEnable } from '@/api/queries/profile';
import { Alert } from '@/components/feedback/Alert';
import { useToast } from '@/components/feedback/toast-context';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { buildTotpCodeSchema, type TotpCodeFormValues } from '@/features/settings/profile/schemas';
import { isApiError } from '@/lib/errors';

export interface TwoFactorCardProps {
  enabled: boolean;
}

/**
 * Settings › Security «Two-factor authentication» (7.13.7).
 *
 * Yoqish oqimi: `POST /auth/2fa/setup` (QR/secret) → `POST /auth/2fa/verify`
 * (kod tasdiqlash) — mavjud endpointlar (`features/auth` bilan bir xil,
 * lekin `features/a → features/b` importi taqiqlangani uchun — fe-conventions
 * §2 — mustaqil qayta amalga oshirilgan, nusxa ko'chirilmagan).
 *
 * **D42 (backend bo'shlig'i):** 2FA'ni o'chirish endpointi swagger'da yo'q —
 * yoqilgandan keyin o'chirish tugmasi ko'rsatilmaydi, o'rniga izoh matni
 * (`docs/tz/16-17-registry-open-questions.md`).
 */
export function TwoFactorCard({ enabled }: TwoFactorCardProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const [enrolling, setEnrolling] = useState(false);
  const [qrDataUrl, setQrDataUrl] = useState<string | null>(null);
  const [secret, setSecret] = useState<string | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [formError, setFormError] = useState<string | null>(null);

  const setupStart = useTotpSetupStart();
  const verify = useTotpVerifyEnable();

  const schema = useMemo(() => buildTotpCodeSchema(t), [t]);
  const form = useForm<TotpCodeFormValues>({
    resolver: zodResolver(schema),
    defaultValues: { code: '' },
    mode: 'onBlur',
  });
  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = form;

  const beginEnrolment = () => {
    setEnrolling(true);
    setLoadError(null);
    setQrDataUrl(null);
    setSecret(null);
    setupStart.mutate(undefined, {
      onSuccess: (setup) => {
        setSecret(setup.secret ?? null);
        if (setup.otpauth_url) {
          void QRCode.toDataURL(setup.otpauth_url).then(setQrDataUrl);
        }
      },
      onError: () => {
        setLoadError(t('settings.security.twoFactor.loadError'));
      },
    });
  };

  const cancelEnrolment = () => {
    setEnrolling(false);
    setQrDataUrl(null);
    setSecret(null);
    setLoadError(null);
    setFormError(null);
    reset({ code: '' });
  };

  const onSubmit = handleSubmit(async (values) => {
    setFormError(null);
    try {
      const result = await verify.mutateAsync({ code: values.code });
      if (result.enabled) {
        toast.show({ variant: 'success', message: t('settings.security.twoFactor.successToast') });
        setEnrolling(false);
        // Xavfsizlik: TOTP siri va QR yoqilgandan keyin xotirada qoldirilmaydi.
        setSecret(null);
        setQrDataUrl(null);
        reset({ code: '' });
      }
    } catch (error) {
      if (isApiError(error) && Object.keys(error.fields).length === 0) {
        setFormError(t('settings.security.twoFactor.invalidCode'));
        return;
      }
      setFormError(t('errors.unknown'));
    }
  });

  return (
    <Card title={t('settings.security.twoFactor.title')}>
      <div className="flex flex-col gap-4">
        <div className="flex items-center justify-between gap-4">
          <p className="text-body text-neutral-700">
            {enabled
              ? t('settings.security.twoFactor.enabledDescription')
              : t('settings.security.twoFactor.disabledDescription')}
          </p>
          <Badge tone={enabled ? 'success' : 'neutral'}>
            {enabled
              ? t('settings.profile.twoFactorEnabled')
              : t('settings.profile.twoFactorDisabled')}
          </Badge>
        </div>

        {enabled ? (
          <Alert message={t('settings.security.twoFactor.disableUnavailable')} variant="info" />
        ) : !enrolling ? (
          <div>
            <Button onClick={beginEnrolment} loading={setupStart.isPending} type="button">
              {t('settings.security.twoFactor.enableButton')}
            </Button>
          </div>
        ) : (
          <form
            className="flex flex-col gap-4"
            noValidate
            onSubmit={(event) => {
              void onSubmit(event);
            }}
          >
            {loadError ? <Alert message={loadError} /> : null}

            {qrDataUrl ? (
              <div className="flex flex-col items-center gap-3">
                <img
                  alt={t('settings.security.twoFactor.qrAlt')}
                  className="h-40 w-40"
                  height={160}
                  src={qrDataUrl}
                  width={160}
                />
                {secret ? (
                  <p className="text-center text-body-sm text-neutral-600">
                    {t('settings.security.twoFactor.manualEntry')}{' '}
                    <code className="font-mono">{secret}</code>
                  </p>
                ) : null}
              </div>
            ) : null}

            {formError ? <Alert message={formError} /> : null}

            <Input
              autoComplete="one-time-code"
              error={errors.code?.message}
              inputMode="numeric"
              label={t('settings.security.twoFactor.codeLabel')}
              maxLength={6}
              required
              {...register('code')}
            />

            <div className="flex gap-2">
              <Button loading={verify.isPending} type="submit">
                {t('settings.security.twoFactor.verifyButton')}
              </Button>
              <Button onClick={cancelEnrolment} type="button" variant="secondary">
                {t('settings.security.twoFactor.cancelButton')}
              </Button>
            </div>
          </form>
        )}
      </div>
    </Card>
  );
}

export default TwoFactorCard;
