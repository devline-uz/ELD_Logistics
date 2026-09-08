import { zodResolver } from '@hookform/resolvers/zod';
import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';

import { resetPassword } from '@/api/auth.api';
import { AuthLayout } from '@/app/layouts/AuthLayout';
import { Alert } from '@/components/feedback/Alert';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { PasswordStrength } from '@/features/auth/components/PasswordStrength';
import { resetPasswordSchema, type ResetPasswordFormValues } from '@/features/auth/schemas';
import { isApiError } from '@/lib/errors';
import { useToast } from '@/components/feedback/toast-context';

/** `/reset-password?token=` — TZ §7.1.3. */
export function ResetPasswordPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const toast = useToast();
  const [searchParams] = useSearchParams();
  const token = searchParams.get('token') ?? '';
  const [formError, setFormError] = useState<string | null>(null);

  const form = useForm<ResetPasswordFormValues>({
    resolver: zodResolver(resetPasswordSchema),
    defaultValues: { password: '', confirmPassword: '' },
    mode: 'onBlur',
  });
  const {
    register,
    handleSubmit,
    watch,
    formState: { errors, isSubmitting },
  } = form;

  const password = watch('password');

  const onSubmit = handleSubmit(async (values) => {
    setFormError(null);
    try {
      await resetPassword({ token, password: values.password });
      toast.show({ variant: 'success', message: t('auth.resetPassword.success') });
      void navigate('/login', { replace: true });
    } catch (error) {
      // Token noto'g'ri/muddati o'tgan bo'lsa backend `fields` bermaydi —
      // umumiy xato o'rniga aniq tarjima qilingan xabar ko'rsatiladi.
      if (isApiError(error) && Object.keys(error.fields).length === 0) {
        setFormError(t('auth.resetPassword.invalidToken'));
        return;
      }
      const { formMessage } = applyServerErrors(form, error);
      if (formMessage) setFormError(formMessage);
    }
  });

  if (!token) {
    return (
      <AuthLayout>
        <Alert message={t('auth.resetPassword.missingToken')} />
        <Link className="mt-6 inline-block text-sm underline" to="/forgot-password">
          {t('auth.forgotPassword.backToLogin')}
        </Link>
      </AuthLayout>
    );
  }

  return (
    <AuthLayout>
      <h1 className="mb-6 text-xl font-semibold text-neutral-900">
        {t('pages.resetPassword.title')}
      </h1>

      <form
        className="flex flex-col gap-4"
        noValidate
        onSubmit={(event) => {
          void onSubmit(event);
        }}
      >
        {formError ? <Alert message={formError} /> : null}

        <Input
          autoComplete="new-password"
          error={errors.password?.message}
          label={t('auth.resetPassword.fields.password')}
          required
          type="password"
          {...register('password')}
        />
        <PasswordStrength password={password} />

        <Input
          autoComplete="new-password"
          error={errors.confirmPassword?.message}
          label={t('auth.resetPassword.fields.confirmPassword')}
          required
          type="password"
          {...register('confirmPassword')}
        />

        <Button fullWidth loading={isSubmitting} type="submit">
          {t('auth.resetPassword.submit')}
        </Button>
      </form>
    </AuthLayout>
  );
}

export default ResetPasswordPage;
