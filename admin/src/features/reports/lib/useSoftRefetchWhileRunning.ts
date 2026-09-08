/**
 * Ro'yxatda `queued`/`running` job bor ekan — ro'yxatni yumshoq (fonda) yangilab
 * turadi (7.8.7 "Ro'yxatda running joblar bo'lsa yumshoq yangilanish"). Yangi interval
 * o'ylab topilmagan — `useExportJob` poll konstantalarining barqaror bosqichi
 * (`EXPORT_JOB_POLL_INTERVALS_MS`ning oxirgi qiymati, 10s) qayta ishlatiladi.
 */
import { useEffect } from 'react';

import { EXPORT_JOB_POLL_INTERVALS_MS } from '@/api/queries/reports';

const STABLE_INTERVAL_MS = EXPORT_JOB_POLL_INTERVALS_MS[EXPORT_JOB_POLL_INTERVALS_MS.length - 1];

export function useSoftRefetchWhileRunning(hasRunningJobs: boolean, refetch: () => void): void {
  useEffect(() => {
    if (!hasRunningJobs) {
      return;
    }
    const id = setInterval(() => {
      refetch();
    }, STABLE_INTERVAL_MS);
    return () => clearInterval(id);
  }, [hasRunningJobs, refetch]);
}
