/**
 * Activity Report — detal ekrani, `/reports/activity/:subjectId` (7.8.1).
 * Breadcrumb: `Activity Report › <nom>`.
 *
 * **D31.5 (backend bo'shlig'i, `docs/tz/16-17-registry-open-questions.md`):** kunlik
 * detal qatorlarini (`# · Date · Start · Duration · Location · Odometer · Eng. Hrs ·
 * Document · Notes`) qaytaradigan endpoint swagger'da **mavjud emas** — na
 * `/reports/activity/{id}`, na boshqa hech qanday marshrut shu shaklda ma'lumot bermaydi.
 * Ekran shakli (breadcrumb, ustunlar) tayyor, lekin ma'lumot o'rniga doimiy
 * "not available" holati ko'rsatiladi — backend CR tayyor bo'lganda faqat query qatlami
 * qo'shiladi, bu sahifa deyarli o'zgarmaydi.
 */
import { useTranslation } from 'react-i18next';
import { useLocation, useNavigate, useParams } from 'react-router-dom';

import { Breadcrumb } from '@/components/ui/Breadcrumb';
import { Button } from '@/components/ui/Button';
import { EmptyState } from '@/components/feedback/EmptyState';

interface ActivityDetailLocationState {
  name?: string;
  subject?: 'drivers' | 'units';
}

const DETAIL_COLUMN_KEYS = [
  'index',
  'date',
  'start',
  'duration',
  'location',
  'odometer',
  'engineHours',
  'document',
  'notes',
] as const;

export function ActivityReportDetailPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { subjectId } = useParams<{ subjectId: string }>();
  const location = useLocation();
  const state = (location.state ?? {}) as ActivityDetailLocationState;
  const name = state.name ?? subjectId ?? '';

  return (
    <div className="flex flex-col gap-4">
      <Breadcrumb
        items={[
          { label: t('reports.activityReport.title'), href: '/reports/activity' },
          { label: name },
        ]}
      />

      <h1 className="text-h3 font-bold text-neutral-900">{name}</h1>

      <div className="overflow-x-auto rounded-lg border border-stroke bg-surface">
        <table className="w-full text-start text-body-sm">
          <thead className="bg-surface-muted text-neutral-500">
            <tr>
              {DETAIL_COLUMN_KEYS.map((key) => (
                <th key={key} className="px-3 py-2 text-start font-medium uppercase tracking-wide">
                  {t(`reports.activityReport.detail.columns.${key}`)}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            <tr>
              <td colSpan={DETAIL_COLUMN_KEYS.length} className="p-0">
                <EmptyState
                  title={t('reports.activityReport.detail.unavailableTitle')}
                  description={t('reports.activityReport.detail.unavailableDescription')}
                  action={
                    <Button variant="secondary" onClick={() => navigate('/reports/activity')}>
                      {t('reports.activityReport.detail.backLink')}
                    </Button>
                  }
                />
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  );
}

export default ActivityReportDetailPage;
