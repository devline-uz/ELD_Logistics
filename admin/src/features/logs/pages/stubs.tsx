import { PageStub } from '@/components/feedback/PageStub';

/** Bosqich 0 joy egallovchi ekranlar — Bosqich 3 da haqiqiy sahifalar bilan almashtiriladi. */
export const LogsByUnitPage = () => <PageStub titleKey="pages.logsByUnit.title" stage={3} />;
export const LogsByDriverPage = () => <PageStub titleKey="pages.logsByDriver.title" stage={3} />;
export const LogViewPage = () => <PageStub titleKey="pages.logView.title" stage={3} />;
export const LogEditRequestsPage = () => (
  <PageStub titleKey="pages.logEditRequests.title" stage={3} />
);
export const UnassignedDrivingPage = () => (
  <PageStub titleKey="pages.unassignedDriving.title" stage={3} />
);
export const ViolationsPage = () => <PageStub titleKey="pages.violations.title" stage={3} />;
