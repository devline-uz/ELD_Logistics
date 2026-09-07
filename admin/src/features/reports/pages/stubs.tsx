import { PageStub } from '@/components/feedback/PageStub';

/** Bosqich 0 joy egallovchi ekranlar — Bosqich 6 da haqiqiy sahifalar bilan almashtiriladi. */
export const ActivityReportPage = () => (
  <PageStub titleKey="pages.reportActivity.title" stage={6} />
);
export const DistanceByRegionPage = () => (
  <PageStub titleKey="pages.reportDistanceByRegion.title" stage={6} />
);
export const RegulatorExportPage = () => (
  <PageStub titleKey="pages.reportRegulator.title" stage={6} />
);
export const DvirReportPage = () => <PageStub titleKey="pages.reportDvir.title" stage={6} />;
export const UncertifiedLogsPage = () => (
  <PageStub titleKey="pages.reportUncertified.title" stage={6} />
);
export const ExportJobsPage = () => <PageStub titleKey="pages.reportExports.title" stage={6} />;
