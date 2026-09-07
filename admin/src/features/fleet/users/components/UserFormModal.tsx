/**
 * User — Invite/Edit modal (2.8, TZ 7.3.9, fe-screens §2/§3).
 *
 * D2 [MUST]: hech qanday `type="password"` maydon yo'q.
 */
import { useEffect, useMemo, useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useTranslation } from 'react-i18next';

import { useRolesList } from '@/api/queries/roles';
import type { User, UserCreate, UserUpdate } from '@/api/types';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { FormInput } from '@/components/form/FormInput';
import { FormSelect } from '@/components/form/FormSelect';
import { Alert } from '@/components/feedback/Alert';
import { Button } from '@/components/ui/Button';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { Modal } from '@/components/ui/Modal';

import {
  userCreateSchema,
  userUpdateSchema,
  type UserCreateFormValues,
  type UserUpdateFormValues,
} from '../schemas';

export interface UserFormModalProps {
  open: boolean;
  onClose: () => void;
  user?: User;
  onSubmitCreate: (body: UserCreate) => Promise<unknown>;
  onSubmitUpdate: (body: UserUpdate) => Promise<unknown>;
  submitting?: boolean;
}

export function UserFormModal({
  open,
  onClose,
  user,
  onSubmitCreate,
  onSubmitUpdate,
  submitting = false,
}: UserFormModalProps) {
  const { t } = useTranslation();
  const isEdit = Boolean(user);
  const [formError, setFormError] = useState<string | undefined>();
  const [discardConfirmOpen, setDiscardConfirmOpen] = useState(false);

  const rolesQuery = useRolesList({ per_page: 50 });
  const roleOptions = useMemo(
    () =>
      (rolesQuery.data?.data ?? [])
        .filter((role) => role.scope !== 'self')
        .map((role) => ({ value: role.id ?? '', label: role.name ?? role.id ?? '' })),
    [rolesQuery.data],
  );

  const defaultValues: UserCreateFormValues | UserUpdateFormValues = useMemo(
    () => ({
      first_name: user?.first_name ?? '',
      last_name: user?.last_name ?? '',
      username: user?.username ?? '',
      email: user?.email ?? '',
      phone: user?.phone ?? '',
      role_id: user?.role?.id ?? '',
      branch_id: user?.branch_id ?? '',
    }),
    [user],
  );

  const form = useForm<UserCreateFormValues | UserUpdateFormValues>({
    resolver: zodResolver(isEdit ? userUpdateSchema : userCreateSchema),
    mode: 'onBlur',
    defaultValues,
  });

  useEffect(() => {
    if (open) {
      form.reset(defaultValues);
      setFormError(undefined);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, user?.id]);

  const handleClose = () => {
    if (form.formState.isDirty) {
      setDiscardConfirmOpen(true);
      return;
    }
    onClose();
  };

  const onSubmit = form.handleSubmit(async (values) => {
    setFormError(undefined);
    try {
      if (isEdit) {
        await onSubmitUpdate({
          first_name: values.first_name,
          last_name: values.last_name,
          username: values.username || undefined,
          email: values.email || undefined,
          phone: values.phone || undefined,
          role_id: values.role_id || undefined,
          branch_id: values.branch_id || undefined,
        });
      } else {
        const createValues = values as UserCreateFormValues;
        await onSubmitCreate({
          first_name: createValues.first_name,
          last_name: createValues.last_name,
          username: createValues.username,
          email: createValues.email || undefined,
          phone: createValues.phone || undefined,
          role_id: createValues.role_id,
          branch_id: createValues.branch_id || undefined,
        });
      }
      onClose();
    } catch (error) {
      const result = applyServerErrors(form, error);
      if (result.formMessage) setFormError(result.formMessage);
    }
  });

  return (
    <>
      <Modal
        open={open}
        onClose={handleClose}
        size="md"
        title={isEdit ? t('fleetUsers.form.editTitle') : t('fleetUsers.form.inviteTitle')}
        footer={
          <>
            <Button variant="secondary" onClick={handleClose} disabled={submitting}>
              {t('common.actions.cancel')}
            </Button>
            <Button onClick={() => void onSubmit()} loading={submitting} disabled={submitting}>
              {isEdit ? t('common.actions.saveChanges') : t('fleetUsers.form.sendInvite')}
            </Button>
          </>
        }
      >
        <form className="flex flex-col gap-4" onSubmit={(event) => void onSubmit(event)} noValidate>
          {formError ? <Alert variant="error" message={formError} /> : null}

          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <FormInput
              name="first_name"
              control={form.control}
              label={t('fleetUsers.form.firstName')}
              required
            />
            <FormInput
              name="last_name"
              control={form.control}
              label={t('fleetUsers.form.lastName')}
              required
            />
            <FormInput
              name="username"
              control={form.control}
              label={t('fleetUsers.form.username')}
              required={!isEdit}
              description={t('fleetUsers.form.usernameHint')}
            />
            <FormInput
              name="email"
              control={form.control}
              type="email"
              label={t('fleetUsers.form.email')}
              required
              description={t('fleetUsers.form.emailOrPhoneHint')}
            />
            <FormInput name="phone" control={form.control} label={t('fleetUsers.form.phone')} />
            <FormSelect
              name="role_id"
              control={form.control}
              label={t('fleetUsers.form.role')}
              options={roleOptions}
              required
              searchable
              loading={rolesQuery.isLoading}
            />
          </div>
        </form>
      </Modal>

      <ConfirmDialog
        open={discardConfirmOpen}
        onClose={() => setDiscardConfirmOpen(false)}
        onConfirm={() => {
          setDiscardConfirmOpen(false);
          onClose();
        }}
        title={t('ui.form.discard.title')}
        description={t('ui.form.discard.description')}
        confirmLabel={t('ui.form.discard.confirm')}
      />
    </>
  );
}

export default UserFormModal;
