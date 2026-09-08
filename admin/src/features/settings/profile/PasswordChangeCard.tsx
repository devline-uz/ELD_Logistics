import { zodResolver } from '@hookform/resolvers/zod';
import { useMemo, useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';

import { useRequestPasswordResetEmail } from '@/api/queries/profile';
import { Alert } from '@/components/feedback/Alert';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { useToast } from '@/components/feedback/toast-context';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import {
  buildPasswordChangeSchema,
  type PasswordChangeFormValues,
} from '@/features/settings/profile/schemas';

export interface PasswordChangeCardProps {
  /** `profile.username` — `POST /auth/password/forgot` `login` maydoni uchun. */
  username: string;
}

/**
 * Settings › Security «Change password» (7.13.7, F151).
 *
 * **D41 (backend bo'shlig'i):** joriy parol bilan bevosita almashtirish
 * endpointi (`POST /auth/password/change` yoki shunga o'xshash) swagger'da
 * yo'q — faqat email-token asosidagi `forgot`/`reset` jufti bor
 * (`docs/tz/16-17-registry-open-questions.md`).
 *
 * MVP: forma F151 talab qilgan uchta maydonni (joriy/yangi/tasdiq parol)
 * to'liq validatsiya bilan ko'rsatadi — `currentPassword` foydalanuvchi
 * hozirgi parolini bilishini mijoz tomonida tasdiqlaydi, lekin hech qayerga
 * yuborilmaydi (yubora oladigan endpoint yo'q). Submit — mavjud
 * `POST /auth/password/forgot` orqali reset-havolasi emailga yuboriladi.
 */
export function PasswordChangeCard({ username }: PasswordChangeCardProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const [formError, setFormError] = useState<string | null>(null);

  const schema = useMemo(() => buildPasswordChangeSchema(t), [t]);
  const form = useForm<PasswordChangeFormValues>({
    resolver: zodResolver(schema),
    defaultValues: { currentPassword: '', newPassword: '', confirmPassword: '' },
    mode: 'onBlur',
  });
  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = form;

  const mutation = useRequestPasswordResetEmail();

  const onSubmit = handleSubmit(async () => {
    setFormError(null);
    try {
      await mutation.mutateAsync({ login: username });
      toast.show({ variant: 'success', message: t('settings.security.password.success') });
      // Xavfsizlik: kiritilgan parollar hech qachon saqlanmaydi/yuborilmaydi —
      // muvaffaqiyatli yuborishdan keyin forma darhol tozalanadi.
      reset({ currentPassword: '', newPassword: '', confirmPassword: '' });
    } catch (error) {
      const { formMessage } = applyServerErrors(form, error);
      setFormError(formMessage ?? t('settings.security.password.error'));
    }
  });

  return (
    <Card title={t('settings.security.password.title')}>
      <form
        className="flex flex-col gap-4"
        noValidate
        onSubmit={(event) => {
          void onSubmit(event);
        }}
      >
        <Alert message={t('settings.security.password.notice')} variant="info" />

        {formError ? <Alert message={formError} /> : null}

        <Input
          autoComplete="current-password"
          error={errors.currentPassword?.message}
          label={t('settings.security.password.currentLabel')}
          required
          type="password"
          {...register('currentPassword')}
        />
        <Input
          autoComplete="new-password"
          error={errors.newPassword?.message}
          label={t('settings.security.password.newLabel')}
          required
          type="password"
          {...register('newPassword')}
        />
        <Input
          autoComplete="new-password"
          error={errors.confirmPassword?.message}
          label={t('settings.security.password.confirmLabel')}
          required
          type="password"
          {...register('confirmPassword')}
        />

        <div>
          <Button loading={mutation.isPending} type="submit">
            {t('settings.security.password.submit')}
          </Button>
        </div>
      </form>
    </Card>
  );
}

export default PasswordChangeCard;
