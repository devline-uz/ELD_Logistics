/**
 * `GET /dvir-reports` va `/dvir-reports/pending-certification` matn qidiruviga
 * ega emas (swagger) — `search` joriy sahifa ichida haydovchi/unit bo'yicha
 * mijoz tomonida filtrlanadi (Violations ekranidagi bilan bir xil naqsh).
 */
import type { DvirReport } from '@/api/types';
import { formatPersonName } from '@/lib/format';

export function filterBySearch(reports: DvirReport[], term: string): DvirReport[] {
  const needle = term.trim().toLowerCase();
  if (!needle) return reports;
  return reports.filter((report) => {
    const driver = formatPersonName(report.driver, '');
    return `${driver} ${report.unit_number ?? ''}`.toLowerCase().includes(needle);
  });
}
