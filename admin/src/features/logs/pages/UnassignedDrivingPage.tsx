/**
 * Unassigned Driving — `/logs/unassigned` (3.12, `docs/tz/07-4-logs.md`
 * 7.4.5) 🎨.
 *
 * **OR ruxsat istisnosi [MUST]**: ro'yxatni ochish
 * `can.any([logs.assign_unidentified, logs.read])` — bitta kalit bilan
 * tekshirilsa faqat `logs.read`ga ega foydalanuvchi ekranni yo'qotadi.
 * Route darajasida `RouteGuard` allaqachon shu OR bilan sozlangan
 * (`app/router/logs.routes.tsx`); bu yerda yozuv amallari (`Assign`/
 * `Annotate`) o'z alohida kalitlari bilan qo'shimcha yopiladi.
 */
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';

import { useUnidentifiedAnnotate, useUnidentifiedEventsList } from '@/api/queries/unidentified';
import type { TrackingUnidentifiedEvent, UnidentifiedEventsListParams } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { FiltersBar, type FilterDef } from '@/components/data/FiltersBar';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { useToast } from '@/components/feedback/toast-context';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useListParams } from '@/hooks/useListParams';
import { useUnitSystem } from '@/hooks/useUnitSystem';
import { PERM, usePermission } from '@/lib/permissions';

import { AssignDriverModal } from '../components/AssignDriverModal';
import { buildUnassignedColumns } from '../components/unassignedColumns';

export function UnassignedDrivingPage() {
  const { t } = useTranslation();
  const toast = useToast();
  const dateFormat = useDateFormat();
  const unitSystem = useUnitSystem();
  const can = usePermission();

  const listParams = useListParams();

  const [assigning, setAssigning] = useState<TrackingUnidentifiedEvent | undefined>(undefined);
  const [annotating, setAnnotating] = useState<TrackingUnidentifiedEvent | undefined>(undefined);

  const queryParams = useMemo<UnidentifiedEventsListParams>(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      status: (listParams.filters.status as UnidentifiedEventsListParams['status']) || undefined,
      unit_id: listParams.filters.unit_id || undefined,
    }),
    [listParams.page, listParams.perPage, listParams.filters.status, listParams.filters.unit_id],
  );

  const list = useUnidentifiedEventsList(queryParams);
  const annotate = useUnidentifiedAnnotate();

  // `GET /unidentified-events` matn qidiruviga ega emas (swagger) —
  // LogsByUnitPage/ViolationsPage'dagi naqshga o'xshab, `search` joriy
  // sahifa ichida `unit_number` bo'yicha mijoz tomonida filtrlanadi.
  const searchTerm = listParams.search.trim().toLowerCase();
  const rows = useMemo(() => {
    const all = list.data?.data ?? [];
    if (!searchTerm) return all;
    return all.filter((event) => (event.unit_number ?? '').toLowerCase().includes(searchTerm));
  }, [list.data, searchTerm]);

  const handleAnnotateConfirm = async (annotation?: string) => {
    if (!annotating?.id || !annotation) return;
    try {
      await annotate.mutateAsync({ id: annotating.id, body: { annotation } });
      toast.show({
        variant: 'success',
        message: t('logs.unassigned.toast.annotated', { unitNumber: annotating.unit_number }),
      });
      setAnnotating(undefined);
    } catch {
      toast.show({ variant: 'error', message: t('logs.unassigned.toast.annotateFailed') });
    }
  };

  const columns = buildUnassignedColumns(t, {
    startIndex: (listParams.page - 1) * listParams.perPage,
    dateFormat,
    unitSystem,
    canAssign: can(PERM.logsAssignUnidentified),
    canAnnotate: can(PERM.logsAnnotateUnidentified),
    onAssign: (event) => setAssigning(event),
    onAnnotate: (event) => setAnnotating(event),
  });

  const filterDefs: FilterDef[] = [
    {
      key: 'status',
      label: t('logs.unassigned.filters.status'),
      options: [
        { value: 'pending', label: t('logs.unassigned.status.pending') },
        { value: 'assigned', label: t('logs.unassigned.status.assigned') },
        { value: 'annotated', label: t('logs.unassigned.status.annotated') },
      ],
    },
  ];

  return (
    <>
      <ListScreen
        title={t('logs.unassigned.title')}
        filtersBar={
          <FiltersBar
            search={listParams.search}
            onSearchChange={listParams.setSearch}
            searchPlaceholder={t('logs.unassigned.filters.searchPlaceholder')}
            filters={filterDefs}
            activeFilters={listParams.filters}
            onFilterChange={listParams.setFilter}
            onClearAll={listParams.clearFilters}
          />
        }
        table={
          <DataTable
            tableId="unassigned-driving"
            columns={columns}
            data={rows}
            isLoading={list.isLoading}
            isError={list.isError}
            errorMessage={list.error?.message}
            onRetry={() => void list.refetch()}
            emptyTitle={t('logs.unassigned.empty.title')}
            emptyDescription={
              listParams.hasActiveFilters
                ? t('logs.unassigned.empty.filteredDescription')
                : t('logs.unassigned.empty.description')
            }
            onClearFilters={listParams.hasActiveFilters ? listParams.clearFilters : undefined}
            getRowId={(event, index) => event.id ?? String(index)}
          />
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

      {assigning ? (
        <AssignDriverModal
          open
          onClose={() => setAssigning(undefined)}
          event={assigning}
          onAssigned={() => setAssigning(undefined)}
        />
      ) : null}

      <ConfirmDialog
        open={Boolean(annotating)}
        onClose={() => setAnnotating(undefined)}
        onConfirm={(annotation) => void handleAnnotateConfirm(annotation)}
        loading={annotate.isPending}
        requireReason
        reasonLabel={t('logs.unassigned.annotateDialog.reasonLabel')}
        title={t('logs.unassigned.annotateDialog.title')}
        description={t('logs.unassigned.annotateDialog.description', {
          unitNumber: annotating?.unit_number,
        })}
      />
    </>
  );
}

export default UnassignedDrivingPage;
