/**
 * Defect Types jadval ustunlari (§7.6.1): `Name · Category · Critical ·
 * Active · Action`.
 *
 * **F114**: dizayndagi 44 bandli truck ro'yxatidagi dublikat `Engine` yozuvi
 * va `Refresh` bandi (nuqson emas) **takrorlanmaydi** — katalog to'liq
 * backenddan (`GET /defect-types`) keladi, kodda qat'iy ro'yxat yo'q.
 */
import type { ColumnDef } from '@tanstack/react-table';
import type { TFunction } from 'i18next';

import type { DefectType } from '@/api/types';
import { RowActionsMenu, type RowActionItem } from '@/components/data/RowActionsMenu';
import { Badge } from '@/components/ui/Badge';

export interface DefectTypeColumnsOptions {
  /** Amal menyusi elementlari — ruxsat va `is_system` tekshiruvi sahifada. */
  buildActions: (defectType: DefectType) => RowActionItem[];
}

export function buildDefectTypeColumns(
  t: TFunction,
  options: DefectTypeColumnsOptions,
): ColumnDef<DefectType, unknown>[] {
  return [
    {
      id: 'name',
      header: t('dvir.defectTypes.columns.name'),
      enableHiding: false,
      cell: ({ row }) => (
        <span className="inline-flex items-center gap-2">
          <span>{row.original.name ?? t('common.na')}</span>
          {row.original.is_system ? (
            <Badge tone="neutral">{t('dvir.defectTypes.system')}</Badge>
          ) : null}
        </span>
      ),
    },
    {
      id: 'category',
      header: t('dvir.defectTypes.columns.category'),
      cell: ({ row }) =>
        row.original.category
          ? t(`enums.defect_category.${row.original.category}`)
          : t('common.na'),
    },
    {
      id: 'is_critical',
      header: t('dvir.defectTypes.columns.critical'),
      cell: ({ row }) =>
        row.original.is_critical ? (
          <Badge tone="error">{t('common.boolean.yes')}</Badge>
        ) : (
          <Badge tone="neutral">{t('common.boolean.no')}</Badge>
        ),
    },
    {
      id: 'is_active',
      header: t('dvir.defectTypes.columns.active'),
      cell: ({ row }) =>
        row.original.is_active ? (
          <Badge tone="success">{t('common.boolean.yes')}</Badge>
        ) : (
          <Badge tone="neutral">{t('common.boolean.no')}</Badge>
        ),
    },
    {
      id: 'action',
      header: t('dvir.defectTypes.columns.action'),
      enableHiding: false,
      enableSorting: false,
      cell: ({ row }) => {
        const items = options.buildActions(row.original);
        if (items.length === 0) return null;
        return <RowActionsMenu items={items} ariaLabel={t('common.actions.more')} />;
      },
    },
  ];
}
