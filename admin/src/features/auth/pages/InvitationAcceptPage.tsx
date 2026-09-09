import { zodResolver } from '@hookform/resolvers/zod';
import { useMemo, useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { useNavigate, useSearchParams } from 'react-router-dom';

import { acceptInvitation } from '@/api/auth.api';
import { AuthLayout } from '@/app/layouts/AuthLayout';
import { Alert } from '@/components/feedback/Alert';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { PasswordStrength } from '@/features/auth/components/PasswordStrength';
import {
  buildInvitationAcceptSchema,
  type InvitationAcceptFormValues,
} from '@/features/auth/schemas';
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
  const schema = useMemo(() => buildInvitationAcceptSchema(t), [t]);
  const navigate = useNavigate();
  const toast = useToast();
  const [searchParams] = useSearchParams();
  const token = searchParams.get('token') ?? '';
  const [formError, setFormError] = useState<string | null>(null);

  const form = useForm<InvitationAcceptFormValues>({
    resolver: zodResolver(schema),
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
      await acceptInvitation({ token, password: values.password });
      toast.show({ variant: 'success', message: t('auth.invitationAccept.success') });
      void navigate('/login', { replace: true });
    } catch (error) {
      // Token noto'g'ri/muddati o'tgan bo'lsa backend `fields` bermaydi —
      // umumiy xato o'rniga aniq tarjima qilingan xabar ko'rsatiladi.
      if (isApiError(error) && Object.keys(error.fields).length === 0) {
        setFormError(t('auth.invitationAccept.invalidToken'));
        return;
      }
      const { formMessage } = applyServerErrors(form, error);
      if (formMessage) setFormError(formMessage);
    }
  });

  if (!token) {
    return (
      <AuthLayout>
        <Alert message={t('auth.invitationAccept.missingToken')} />
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
        {formError ? <Alert message={formError} /> : null}

        <Input
          autoComplete="new-password"
          error={errors.password?.message}
          label={t('auth.invitationAccept.fields.password')}
          required
          type="password"
          {...register('password')}
        />
        <PasswordStrength password={password} />

        <Input
          autoComplete="new-password"
          error={errors.confirmPassword?.message}
          label={t('auth.invitationAccept.fields.confirmPassword')}
          required
          type="password"
          {...register('confirmPassword')}
        />

        <Button fullWidth loading={isSubmitting} type="submit">
          {t('auth.invitationAccept.submit')}
        </Button>
      </form>
    </AuthLayout>
  );
}

export default InvitationAcceptPage;
