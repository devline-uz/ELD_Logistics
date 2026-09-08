/**
 * Branches jadval ustunlari (8.3, §7.13.2).
 *
 * ⚠️ **Backend bo'shlig'i (D43, `docs/tz/16-17-registry-open-questions.md`)**:
 * dizayn/TZ ustun ro'yxati `Name · Address · Timezone · Users · Units ·
 * Action` — lekin `company_dto.Branch` (swagger) faqat `id/name/address/
 * timezone/created_at/updated_at` qaytaradi, filialdagi foydalanuvchi/unit
 * sonini beruvchi maydon **yo'q**. `Users`/`Units` ustunlari shu sabab
 * ko'rsatilmaydi (backend hisoblab bermaydi — frontend uydirmaydi).
 */
import type { ColumnDef } from '@tanstack/react-table';
import type { TFunction } from 'i18next';

import type { Branch } from '@/api/types';
import { RowActionsMenu, type RowActionItem } from '@/components/data/RowActionsMenu';

export interface BranchColumnsOptions {
  buildActions: (branch: Branch) => RowActionItem[];
}

export function buildBranchColumns(
  t: TFunction,
  options: BranchColumnsOptions,
): ColumnDef<Branch, unknown>[] {
  return [
    {
      id: 'name',
      header: t('settings.branches.columns.name'),
      enableHiding: false,
      // Backend faqat `name`/`created_at` bo'yicha saralashga ruxsat beradi
      // (`GET /company/branches` `sort` enum) — `created_at` ustuni jadvalda
      // ko'rsatilmagani uchun faqat `name` saralanadigan qilib belgilanadi.
      enableSorting: true,
      cell: ({ row }) => row.original.name ?? t('common.na'),
    },
    {
      id: 'address',
      header: t('settings.branches.columns.address'),
      cell: ({ row }) => row.original.address ?? t('common.na'),
    },
    {
      id: 'timezone',
      header: t('settings.branches.columns.timezone'),
      cell: ({ row }) => row.original.timezone ?? t('common.na'),
    },
    {
      id: 'action',
      header: t('settings.branches.columns.action'),
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
