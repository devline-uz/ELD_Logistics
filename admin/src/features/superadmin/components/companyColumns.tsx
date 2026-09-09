/**
 * Super Admin — Companies jadval ustunlari (9.15, §7.14).
 *
 * Saralash faqat backend ruxsat etadigan maydonlar bo'yicha (`GET /companies`
 * `sort` enum): `name | created_at | subscription_end_at`.
 */
import type { ColumnDef } from '@tanstack/react-table';
import type { TFunction } from 'i18next';

import type { AdminCompany } from '@/api/types';
import { Badge, type BadgeTone } from '@/components/ui/Badge';
import { RowActionsMenu, type RowActionItem } from '@/components/data/RowActionsMenu';
import type { UseDateFormatResult } from '@/hooks/useDateFormat';
import { NA } from '@/lib/format';

export interface CompanyColumnsOptions {
  dateFormat: Pick<UseDateFormatResult, 'formatDate'>;
  buildActions: (company: AdminCompany) => RowActionItem[];
}

const STATUS_TONE: Record<string, BadgeTone> = {
  trial: 'info',
  active: 'success',
  grace: 'warning',
  readonly: 'error',
};

export function buildCompanyColumns(
  t: TFunction,
  options: CompanyColumnsOptions,
): ColumnDef<AdminCompany, unknown>[] {
  return [
    {
      id: 'name',
      header: t('superadmin.companies.columns.name'),
      enableHiding: false,
      enableSorting: true,
      cell: ({ row }) => row.original.name ?? NA,
    },
    {
      id: 'region',
      header: t('superadmin.companies.columns.region'),
      cell: ({ row }) =>
        row.original.region ? t(`superadmin.companies.region.${row.original.region}`) : NA,
    },
    {
      id: 'plan',
      header: t('superadmin.companies.columns.plan'),
      cell: ({ row }) => row.original.plan ?? NA,
    },
    {
      id: 'subscription_status',
      header: t('superadmin.companies.columns.subscriptionStatus'),
      cell: ({ row }) => {
        const status = row.original.subscription_status;
        if (!status) return NA;
        return (
          <Badge tone={STATUS_TONE[status] ?? 'neutral'}>
            {t(`superadmin.companies.status.${status}`)}
          </Badge>
        );
      },
    },
    {
      id: 'subscription_end_at',
      header: t('superadmin.companies.columns.subscriptionEndAt'),
      enableSorting: true,
      cell: ({ row }) => options.dateFormat.formatDate(row.original.subscription_end_at),
    },
    {
      id: 'created_at',
      header: t('superadmin.companies.columns.createdAt'),
      enableSorting: true,
      cell: ({ row }) => options.dateFormat.formatDate(row.original.created_at),
    },
    {
      id: 'action',
      header: t('superadmin.companies.columns.action'),
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
