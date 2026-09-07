import { zodResolver } from '@hookform/resolvers/zod';
import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';

import { requestPasswordReset } from '@/api/auth.api';
import { AuthLayout } from '@/app/layouts/AuthLayout';
import { FormAlert } from '@/features/auth/components/FormAlert';
import { FormField } from '@/features/auth/components/FormField';
import { SubmitButton } from '@/features/auth/components/SubmitButton';
import { forgotPasswordSchema, type ForgotPasswordFormValues } from '@/features/auth/schemas';

/**
 * `/forgot-password` — TZ §7.1.3.
 *
 * Javob har doim bir xil neytral xabar — enumeratsiya hujumiga qarshi
 * (hisob mavjudligini oshkor qilmaslik).
 */
export function ForgotPasswordPage() {
  const { t } = useTranslation();
  const [submitted, setSubmitted] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<ForgotPasswordFormValues>({
    resolver: zodResolver(forgotPasswordSchema),
    defaultValues: { login: '' },
    mode: 'onBlur',
  });

  const onSubmit = handleSubmit(async (values) => {
    try {
      await requestPasswordReset(values);
    } finally {
      // Neytral javob — muvaffaqiyat va xato bir xil ko'rinishda (enumeratsiyaga qarshi).
      setSubmitted(true);
    }
  });

  if (submitted) {
    return (
      <AuthLayout>
        <h1 className="mb-2 text-xl font-semibold text-neutral-900">
          {t('pages.forgotPassword.title')}
        </h1>
        <p aria-live="polite" className="text-sm text-neutral-600" role="status">
          {t('auth.forgotPassword.neutralMessage')}
        </p>
        <Link className="mt-6 inline-block text-sm underline" to="/login">
          {t('auth.forgotPassword.backToLogin')}
        </Link>
      </AuthLayout>
    );
  }

  return (
    <AuthLayout>
      <h1 className="mb-2 text-xl font-semibold text-neutral-900">
        {t('pages.forgotPassword.title')}
      </h1>
      <p className="mb-6 text-sm text-neutral-600">{t('auth.forgotPassword.description')}</p>

      <form
        className="flex flex-col gap-4"
        noValidate
        onSubmit={(event) => {
          void onSubmit(event);
        }}
      >
        {errors.root?.message ? <FormAlert message={errors.root.message} /> : null}

        <FormField
          autoComplete="username"
          error={errors.login?.message}
          label={t('auth.forgotPassword.fields.login')}
          required
          {...register('login')}
        />

        <SubmitButton loading={isSubmitting}>{t('auth.forgotPassword.submit')}</SubmitButton>

        <Link className="text-center text-sm underline" to="/login">
          {t('auth.forgotPassword.backToLogin')}
        </Link>
      </form>
    </AuthLayout>
  );
}

export default ForgotPasswordPage;
