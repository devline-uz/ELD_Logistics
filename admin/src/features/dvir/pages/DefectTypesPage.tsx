/**
 * Defect Types — `/settings/defect-types` (5.12, §7.6.1).
 *
 * `GET /defect-types` (`defect_types.read`), `POST` (`defect_types.create`),
 * `PATCH` (`defect_types.update`). **`DELETE` yo'q** — "o'chirish" o'rniga
 * deaktivatsiya (`is_active=false`), shunda tarixiy DVIR hisobotlari
 * buzilmaydi.
 *
 * **F114**: dizayndagi dublikat `Engine` yozuvi va `Refresh` tugmasi
 * takrorlanmaydi.
 */
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';

import {
  useDefectTypeCreate,
  useDefectTypeUpdate,
  useDefectTypesList,
} from '@/api/queries/defectTypes';
import type { DefectType, DefectTypesListParams } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { FiltersBar, type FilterDef } from '@/components/data/FiltersBar';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import type { RowActionItem } from '@/components/data/RowActionsMenu';
import { useToast } from '@/components/feedback/toast-context';
import { Button } from '@/components/ui/Button';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { useListParams } from '@/hooks/useListParams';
import { PERM, usePermission } from '@/lib/permissions';

import { buildDefectTypeColumns } from '../components/defectTypeColumns';
import { DefectTypeFormModal } from '../components/DefectTypeFormModal';
import { dvirErrorMessageKey } from '../lib/errors';
import type { DefectTypeFormValues } from '../lib/schemas';

function toPayload(values: DefectTypeFormValues) {
  return {
    name: values.name.trim(),
    category: values.category,
    is_critical: values.is_critical,
    is_active: values.is_active,
    ...(values.sort_order.trim() ? { sort_order: Number(values.sort_order) } : {}),
  };
}

export function DefectTypesPage() {
  const { t } = useTranslation();
  const toast = useToast();
  const can = usePermission();
  const listParams = useListParams();

  const [formOpen, setFormOpen] = useState(false);
  const [editing, setEditing] = useState<DefectType | undefined>(undefined);
  const [toggling, setToggling] = useState<DefectType | undefined>(undefined);

  const queryParams = useMemo<DefectTypesListParams>(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      category: (listParams.filters.category as DefectTypesListParams['category']) || undefined,
      is_active:
        listParams.filters.is_active === 'true'
          ? true
          : listParams.filters.is_active === 'false'
            ? false
            : undefined,
      is_critical:
        listParams.filters.is_critical === 'true'
          ? true
          : listParams.filters.is_critical === 'false'
            ? false
            : undefined,
    }),
    [
      listParams.page,
      listParams.perPage,
      listParams.filters.category,
      listParams.filters.is_active,
      listParams.filters.is_critical,
    ],
  );

  const list = useDefectTypesList(queryParams);
  const create = useDefectTypeCreate();
  const update = useDefectTypeUpdate();

  // `GET /defect-types` matn qidiruviga ega emas — `search` joriy sahifa
  // ichida nom bo'yicha mijoz tomonida filtrlanadi.
  const searchTerm = listParams.search.trim().toLowerCase();
  const rows = useMemo(() => {
    const all = list.data?.data ?? [];
    if (!searchTerm) return all;
    return all.filter((item) => (item.name ?? '').toLowerCase().includes(searchTerm));
  }, [list.data, searchTerm]);

  const buildActions = (defectType: DefectType): RowActionItem[] => {
    // Standart (`is_system`) bandlar tahrirlanmaydi — backend `409
    // DEFECT_TYPE_SYSTEM_LOCKED` beradi, shuning uchun amal ko'rsatilmaydi.
    if (defectType.is_system || !can(PERM.defectTypesUpdate)) return [];

    return [
      {
        key: 'edit',
        label: t('common.actions.edit'),
        onSelect: () => {
          setEditing(defectType);
          setFormOpen(true);
        },
      },
      {
        key: 'toggle',
        label: defectType.is_active ? t('common.actions.deactivate') : t('common.actions.activate'),
        danger: Boolean(defectType.is_active),
        onSelect: () => setToggling(defectType),
      },
    ];
  };

  const columns = buildDefectTypeColumns(t, { buildActions });

  const filterDefs: FilterDef[] = [
    {
      key: 'category',
      label: t('dvir.defectTypes.filters.category'),
      options: [
        { value: 'truck', label: t('enums.defect_category.truck') },
        { value: 'trailer', label: t('enums.defect_category.trailer') },
      ],
    },
    {
      key: 'is_active',
      label: t('dvir.defectTypes.filters.isActive'),
      options: [
        { value: 'true', label: t('common.boolean.yes') },
        { value: 'false', label: t('common.boolean.no') },
      ],
    },
    {
      key: 'is_critical',
      label: t('dvir.defectTypes.filters.isCritical'),
      options: [
        { value: 'true', label: t('common.boolean.yes') },
        { value: 'false', label: t('common.boolean.no') },
      ],
    },
  ];

  const confirmToggle = async () => {
    if (!toggling?.id) return;
    const activate = !toggling.is_active;
    try {
      await update.mutateAsync({ id: toggling.id, body: { is_active: activate } });
      toast.show({
        variant: 'success',
        message: activate
          ? t('dvir.defectTypes.toast.activated', { name: toggling.name })
          : t('dvir.defectTypes.toast.deactivated', { name: toggling.name }),
      });
    } catch (error) {
      const moduleKey = dvirErrorMessageKey(error);
      toast.show({
        variant: 'error',
        message: moduleKey ? t(moduleKey) : t('dvir.defectTypes.toast.failed'),
      });
    } finally {
      setToggling(undefined);
    }
  };

  return (
    <ListScreen
      title={t('dvir.defectTypes.title')}
      actions={
        <PermissionGate permission={PERM.defectTypesCreate}>
          <Button
            onClick={() => {
              setEditing(undefined);
              setFormOpen(true);
            }}
          >
            {t('dvir.defectTypes.add')}
          </Button>
        </PermissionGate>
      }
      filtersBar={
        <FiltersBar
          search={listParams.search}
          onSearchChange={listParams.setSearch}
          filters={filterDefs}
          activeFilters={listParams.filters}
          onFilterChange={listParams.setFilter}
          onClearAll={listParams.clearFilters}
        />
      }
      table={
        <>
          <DataTable
            tableId="defect-types"
            columns={columns}
            data={rows}
            isLoading={list.isLoading}
            isError={list.isError}
            errorMessage={list.error?.message}
            onRetry={() => void list.refetch()}
            emptyTitle={
              listParams.hasActiveFilters
                ? t('dvir.defectTypes.empty.filteredTitle')
                : t('dvir.defectTypes.empty.title')
            }
            emptyDescription={
              listParams.hasActiveFilters
                ? t('dvir.defectTypes.empty.filteredDescription')
                : t('dvir.defectTypes.empty.description')
            }
            onClearFilters={listParams.hasActiveFilters ? listParams.clearFilters : undefined}
            getRowId={(item, index) => item.id ?? String(index)}
          />

          <DefectTypeFormModal
            open={formOpen}
            onClose={() => setFormOpen(false)}
            defectType={editing}
            isPending={create.isPending || update.isPending}
            onCreate={(values) => create.mutateAsync(toPayload(values))}
            onUpdate={(id, values) => update.mutateAsync({ id, body: toPayload(values) })}
            onSuccess={(isEdit, values) =>
              toast.show({
                variant: 'success',
                message: isEdit
                  ? t('dvir.defectTypes.toast.updated', { name: values.name })
                  : t('dvir.defectTypes.toast.created', { name: values.name }),
              })
            }
          />

          <ConfirmDialog
            open={Boolean(toggling)}
            onClose={() => setToggling(undefined)}
            onConfirm={() => void confirmToggle()}
            title={t('dvir.defectTypes.deactivate.title')}
            description={t('dvir.defectTypes.deactivate.description', { name: toggling?.name })}
            variant={toggling?.is_active ? 'danger' : 'default'}
            loading={update.isPending}
          />
        </>
      }
      pagination={
        <Pagination
          page={listParams.page}
          perPage={listParams.perPage}
          total={list.data?.meta?.total ?? 0}
          onPageChange={listParams.setPage}
          onPerPageChange={listParams.setPerPage}
        />
      }
    />
  );
}

export default DefectTypesPage;
