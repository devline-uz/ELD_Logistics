/**
 * 104 permission kalitini 28 guruhga bo'lib ko'rsatadi (F90) — Roles
 * Add/Edit formasidagi checkbox ro'yxati. Manba — `GET /permissions`
 * (`usePermissionsList`), hech qachon qo'lda yozilmaydi.
 */
import { useTranslation } from 'react-i18next';

import type { PermissionModule } from '@/api/types';
import { Checkbox } from '@/components/ui/Checkbox';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';

export interface RolePermissionGroupsProps {
  modules: PermissionModule[];
  isLoading: boolean;
  isError: boolean;
  onRetry: () => void;
  selected: string[];
  onChange: (next: string[]) => void;
  disabled?: boolean;
}

export function RolePermissionGroups({
  modules,
  isLoading,
  isError,
  onRetry,
  selected,
  onChange,
  disabled = false,
}: RolePermissionGroupsProps) {
  const { t } = useTranslation();
  const selectedSet = new Set(selected);

  const toggleOne = (key: string, checked: boolean) => {
    if (checked) onChange([...selected, key]);
    else onChange(selected.filter((k) => k !== key));
  };

  const toggleGroup = (moduleDef: PermissionModule, checked: boolean) => {
    const keys = (moduleDef.permissions ?? []).map((p) => p.key).filter(Boolean) as string[];
    if (checked) {
      onChange(Array.from(new Set([...selected, ...keys])));
    } else {
      const keySet = new Set(keys);
      onChange(selected.filter((k) => !keySet.has(k)));
    }
  };

  if (isLoading) {
    return <Skeleton variant="card" count={4} />;
  }

  if (isError) {
    return <ErrorState message={t('fleetRoles.form.permissionsLoadError')} onRetry={onRetry} />;
  }

  return (
    <div className="flex flex-col gap-5">
      {modules.map((moduleDef) => {
        const keys = (moduleDef.permissions ?? []).map((p) => p.key).filter(Boolean) as string[];
        const selectedCount = keys.filter((k) => selectedSet.has(k)).length;
        const allSelected = keys.length > 0 && selectedCount === keys.length;
        const someSelected = selectedCount > 0 && !allSelected;

        return (
          <fieldset key={moduleDef.module} className="rounded-lg border border-stroke p-3">
            <legend className="flex w-full items-center justify-between px-1">
              <span className="text-body font-semibold text-neutral-900">{moduleDef.label}</span>
            </legend>
            <Checkbox
              label={t('fleetRoles.form.selectAllInGroup')}
              checked={allSelected}
              indeterminate={someSelected}
              disabled={disabled}
              onChange={(event) => toggleGroup(moduleDef, event.target.checked)}
              className="mb-2"
            />
            <div className="grid grid-cols-1 gap-2 ps-1 sm:grid-cols-2">
              {(moduleDef.permissions ?? []).map((permission) =>
                permission.key ? (
                  <Checkbox
                    key={permission.key}
                    label={permission.description ?? permission.key}
                    checked={selectedSet.has(permission.key)}
                    disabled={disabled}
                    onChange={(event) => toggleOne(permission.key as string, event.target.checked)}
                  />
                ) : null,
              )}
            </div>
          </fieldset>
        );
      })}
    </div>
  );
}

export default RolePermissionGroups;
