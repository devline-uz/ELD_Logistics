/**
 * Report tabi (7.4.3(c)): `GET /daily-logs/{id}/pdf` (`logs.export`) → PDF
 * ko'rish + yuklab olish.
 *
 * ⚠️ `useDailyLogPdf` **Blob** qaytaradi — `Authorization` header talab
 * qilingani uchun oddiy `<a href="/daily-logs/{id}/pdf">` ISHLATILMAYDI.
 * Blob keladi → `URL.createObjectURL` → `<iframe>` va `<a download>`.
 */
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';

import { useDailyLogPdf } from '@/api/queries/logs';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { Button } from '@/components/ui/Button';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { PERM } from '@/lib/permissions';

export interface ReportTabProps {
  dailyLogId: string;
}

export function ReportTab({ dailyLogId }: ReportTabProps) {
  const { t } = useTranslation();
  const pdf = useDailyLogPdf();
  const [objectUrl, setObjectUrl] = useState<string | undefined>(undefined);

  useEffect(() => {
    let cancelledUrl: string | undefined;
    pdf
      .mutateAsync(dailyLogId)
      .then((blob) => {
        const url = URL.createObjectURL(blob);
        cancelledUrl = url;
        setObjectUrl(url);
      })
      .catch(() => undefined);

    return () => {
      if (cancelledUrl) URL.revokeObjectURL(cancelledUrl);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [dailyLogId]);

  if (pdf.isPending && !objectUrl) {
    return <Skeleton variant="card" count={1} />;
  }

  if (pdf.isError) {
    return (
      <ErrorState
        title={t('logs.view.report.errorTitle')}
        message={pdf.error?.message}
        onRetry={() =>
          void pdf.mutateAsync(dailyLogId).then((blob) => setObjectUrl(URL.createObjectURL(blob)))
        }
      />
    );
  }

  if (!objectUrl) return null;

  return (
    <div className="flex flex-col gap-3">
      <PermissionGate permission={PERM.logsExport}>
        <div className="flex justify-end">
          <a
            href={objectUrl}
            download={`daily-log-${dailyLogId}.pdf`}
            className="inline-flex items-center rounded-md bg-primary px-4 py-2 text-body-sm font-medium text-white hover:bg-primary-hover"
          >
            {t('logs.view.report.download')}
          </a>
        </div>
      </PermissionGate>
      <object
        data={objectUrl}
        type="application/pdf"
        aria-label={t('logs.view.report.title')}
        className="h-[70vh] w-full rounded-lg border border-stroke"
      >
        <Button
          onClick={() => {
            window.open(objectUrl, '_blank', 'noopener,noreferrer');
          }}
        >
          {t('logs.view.report.openInNewTab')}
        </Button>
      </object>
    </div>
  );
}
