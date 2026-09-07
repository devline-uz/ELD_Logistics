import { zodResolver } from '@hookform/resolvers/zod';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { useNavigate, useSearchParams } from 'react-router-dom';

import { acceptInvitation } from '@/api/auth.api';
import { AuthLayout } from '@/app/layouts/AuthLayout';
import { FormAlert } from '@/features/auth/components/FormAlert';
import { FormField } from '@/features/auth/components/FormField';
import { PasswordStrength } from '@/features/auth/components/PasswordStrength';
import { SubmitButton } from '@/features/auth/components/SubmitButton';
import { invitationAcceptSchema, type InvitationAcceptFormValues } from '@/features/auth/schemas';
import { isApiError } from '@/lib/errors';
import { useToast } from '@/components/feedback/toast-context';

/**
 * `/invitation/accept?token=` — TZ §7.1.4.
 *
 * Bu **yagona** parol o'rnatish yo'li (`tz.md` qaror 21) — Driver/User
 * formalarida `Password` maydoni yo'q.
 */
export function InvitationAcceptPage() {
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
  } = useForm<InvitationAcceptFormValues>({
    resolver: zodResolver(invitationAcceptSchema),
    defaultValues: { password: '', confirmPassword: '' },
    mode: 'onBlur',
  });

  const password = watch('password');

  const onSubmit = handleSubmit(async (values) => {
    try {
      await acceptInvitation({ token, password: values.password });
      toast.show({ variant: 'success', message: t('auth.invitationAccept.success') });
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
        setError('password', { message: t('auth.invitationAccept.invalidToken') });
        return;
      }
      setError('password', { message: t('errors.unknown') });
    }
  });

  if (!token) {
    return (
      <AuthLayout>
        <FormAlert message={t('auth.invitationAccept.missingToken')} />
      </AuthLayout>
    );
  }

  return (
    <AuthLayout>
      <h1 className="mb-2 text-xl font-semibold text-neutral-900">
        {t('pages.invitationAccept.title')}
      </h1>
      <p className="mb-6 text-sm text-neutral-600">{t('auth.invitationAccept.description')}</p>

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
          label={t('auth.invitationAccept.fields.password')}
          required
          type="password"
          {...register('password')}
        />
        <PasswordStrength password={password} />

        <FormField
          autoComplete="new-password"
          error={errors.confirmPassword?.message}
          label={t('auth.invitationAccept.fields.confirmPassword')}
          required
          type="password"
          {...register('confirmPassword')}
        />

        <SubmitButton loading={isSubmitting}>{t('auth.invitationAccept.submit')}</SubmitButton>
      </form>
    </AuthLayout>
  );
}

export default InvitationAcceptPage;
