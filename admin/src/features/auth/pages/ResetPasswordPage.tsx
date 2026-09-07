import { zodResolver } from '@hookform/resolvers/zod';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';

import { resetPassword } from '@/api/auth.api';
import { AuthLayout } from '@/app/layouts/AuthLayout';
import { FormAlert } from '@/features/auth/components/FormAlert';
import { FormField } from '@/features/auth/components/FormField';
import { PasswordStrength } from '@/features/auth/components/PasswordStrength';
import { SubmitButton } from '@/features/auth/components/SubmitButton';
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

  const {
    register,
    handleSubmit,
    watch,
    setError,
    formState: { errors, isSubmitting },
  } = useForm<ResetPasswordFormValues>({
    resolver: zodResolver(resetPasswordSchema),
    defaultValues: { password: '', confirmPassword: '' },
    mode: 'onBlur',
  });

  const password = watch('password');

  const onSubmit = handleSubmit(async (values) => {
    try {
      await resetPassword({ token, password: values.password });
      toast.show({ variant: 'success', message: t('auth.resetPassword.success') });
      void navigate('/login', { replace: true });
    } catch (error) {
      if (isApiError(error)) {
        const fieldEntries = Object.entries(error.fields);
        if (fieldEntries.length > 0) {
          for (const [field, message] of fieldEntries) {
            if (field === 'password' || field === 'confirmPassword') {
              setError(field, { message });
            }
          }
          return;
        }
        setError('password', { message: t('auth.resetPassword.invalidToken') });
        return;
      }
      setError('password', { message: t('errors.unknown') });
    }
  });

  if (!token) {
    return (
      <AuthLayout>
        <FormAlert message={t('auth.resetPassword.missingToken')} />
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
        <FormField
          autoComplete="new-password"
          error={errors.password?.message}
          label={t('auth.resetPassword.fields.password')}
          required
          type="password"
          {...register('password')}
        />
        <PasswordStrength password={password} />

        <FormField
          autoComplete="new-password"
          error={errors.confirmPassword?.message}
          label={t('auth.resetPassword.fields.confirmPassword')}
          required
          type="password"
          {...register('confirmPassword')}
        />

        <SubmitButton loading={isSubmitting}>{t('auth.resetPassword.submit')}</SubmitButton>
      </form>
    </AuthLayout>
  );
}

export default ResetPasswordPage;
