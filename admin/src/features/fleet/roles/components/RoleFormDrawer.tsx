/**
 * Role — Add/Edit paneli (2.9, TZ 7.3.10, fe-screens §2/§3).
 *
 * F92 [MUST]: `is_system=true` rollar butunlay tahrirlanmaydi — bu komponent
 * chaqirilganda `role.is_system` bo'lsa hamma maydon `disabled` va footer'da
 * faqat "Close" ko'rinadi (chaqiruvchi `RoleListPage` allaqachon Edit
 * amalini menyudan olib tashlaydi — bu ikkinchi darajali himoya).
 * `Duplicate` — system roldan nusxa olib yangi (tizim bo'lmagan) rol
 * yaratish yo'li.
 */
import { useEffect, useMemo, useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useTranslation } from 'react-i18next';

import { usePermissionsList } from '@/api/queries/permissions';
import type { Role, RoleCreate, RoleUpdate } from '@/api/types';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { FormInput } from '@/components/form/FormInput';
import { FormSelect } from '@/components/form/FormSelect';
import { FormTextarea } from '@/components/form/FormTextarea';
import { Alert } from '@/components/feedback/Alert';
import { Button } from '@/components/ui/Button';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { Drawer } from '@/components/ui/Drawer';

import { roleFormSchema, type RoleFormValues } from '../schemas';
import { RolePermissionGroups } from './RolePermissionGroups';

export interface RoleFormDrawerProps {
  open: boolean;
  onClose: () => void;
  /** Berilsa Edit (yoki `duplicateFrom` bilan Add-nusxa) rejimi. */
  role?: Role;
  /** `true` bo'lsa — `role` faqat boshlang'ich qiymat manbai, natija Add. */
  duplicateFrom?: boolean;
  onSubmitCreate: (body: RoleCreate) => Promise<unknown>;
  onSubmitUpdate: (body: RoleUpdate) => Promise<unknown>;
  submitting?: boolean;
}

export function RoleFormDrawer({
  open,
  onClose,
  role,
  duplicateFrom = false,
  onSubmitCreate,
  onSubmitUpdate,
  submitting = false,
}: RoleFormDrawerProps) {
  const { t } = useTranslation();
  const isEdit = Boolean(role) && !duplicateFrom;
  const isSystemLocked = Boolean(role?.is_system) && !duplicateFrom;
  const [formError, setFormError] = useState<string | undefined>();
  const [discardConfirmOpen, setDiscardConfirmOpen] = useState(false);

  const permissionsQuery = usePermissionsList();

  const defaultValues: RoleFormValues = useMemo(
    () => ({
      name: duplicateFrom ? '' : (role?.name ?? ''),
      description: role?.description ?? '',
      scope: role?.scope === 'branch' ? 'branch' : 'company',
      permissions: role?.permissions ?? [],
    }),
    [role, duplicateFrom],
  );

  const form = useForm<RoleFormValues>({
    resolver: zodResolver(roleFormSchema),
    mode: 'onBlur',
    defaultValues,
  });

  useEffect(() => {
    if (open) {
      form.reset(defaultValues);
      setFormError(undefined);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, role?.id, duplicateFrom]);

  const handleClose = () => {
    if (!isSystemLocked && form.formState.isDirty) {
      setDiscardConfirmOpen(true);
      return;
    }
    onClose();
  };

  const onSubmit = form.handleSubmit(async (values) => {
    if (isSystemLocked) return;
    setFormError(undefined);
    try {
      if (isEdit && role?.id) {
        await onSubmitUpdate({
          name: values.name,
          description: values.description || undefined,
          scope: values.scope,
          permissions: values.permissions,
        });
      } else {
        await onSubmitCreate({
          name: values.name,
          description: values.description || undefined,
          scope: values.scope,
          permissions: values.permissions,
        });
      }
      onClose();
    } catch (error) {
      const result = applyServerErrors(form, error);
      if (result.formMessage) setFormError(result.formMessage);
    }
  });

  const scopeOptions = [
    { value: 'company', label: t('fleetRoles.form.scopeCompany') },
    { value: 'branch', label: t('fleetRoles.form.scopeBranch') },
  ] as const;

  return (
    <>
      <Drawer
        open={open}
        onClose={handleClose}
        size="lg"
        title={
          isEdit
            ? t('fleetRoles.form.editTitle')
            : duplicateFrom
              ? t('fleetRoles.form.duplicateTitle')
              : t('fleetRoles.form.addTitle')
        }
        footer={
          isSystemLocked ? (
            <Button variant="secondary" onClick={onClose}>
              {t('common.actions.close')}
            </Button>
          ) : (
            <>
              <Button variant="secondary" onClick={handleClose} disabled={submitting}>
                {t('common.actions.cancel')}
              </Button>
              <Button onClick={() => void onSubmit()} loading={submitting} disabled={submitting}>
                {isEdit ? t('common.actions.saveChanges') : t('common.actions.add')}
              </Button>
            </>
          )
        }
      >
        <form className="flex flex-col gap-4" onSubmit={(event) => void onSubmit(event)} noValidate>
          {formError ? <Alert variant="error" message={formError} /> : null}

          {isSystemLocked ? (
            <Alert variant="info" message={t('fleetRoles.form.systemLockedNotice')} />
          ) : null}

          <FormInput
            name="name"
            control={form.control}
            label={t('fleetRoles.form.name')}
            required
            disabled={isSystemLocked}
          />
          <FormTextarea
            name="description"
            control={form.control}
            label={t('fleetRoles.form.description')}
            rows={2}
            disabled={isSystemLocked}
          />
          <FormSelect
            name="scope"
            control={form.control}
            label={t('fleetRoles.form.scope')}
            options={scopeOptions}
            required
            disabled={isSystemLocked}
            description={t('fleetRoles.form.scopeHint')}
          />

          <div>
            <h3 className="mb-2 text-body font-semibold text-neutral-900">
              {t('fleetRoles.form.permissionsTitle')}
            </h3>
            {form.formState.errors.permissions ? (
              <p role="alert" className="mb-2 text-body-sm text-error-dark">
                {form.formState.errors.permissions.message}
              </p>
            ) : null}
            <RolePermissionGroups
              modules={permissionsQuery.data ?? []}
              isLoading={permissionsQuery.isLoading}
              isError={permissionsQuery.isError}
              onRetry={() => void permissionsQuery.refetch()}
              selected={form.watch('permissions')}
              onChange={(next) =>
                form.setValue('permissions', next, { shouldDirty: true, shouldValidate: true })
              }
              disabled={isSystemLocked}
            />
          </div>
        </form>
      </Drawer>

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

export default RoleFormDrawer;
