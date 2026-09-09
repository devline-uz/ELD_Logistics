/**
 * Oqim 6 — Maintenance: schedule yaratish → due → mark as complete (invoice
 * yuklash bilan) (§14.4.6).
 */
import { adminTest as test, expect } from './fixtures';

test('create a maintenance schedule, then mark the due unit as complete with an invoice', async ({
  page,
}) => {
  await page.goto('/maintenance/schedules');
  await expect(page.getByRole('heading', { name: 'Maintenance' })).toBeVisible();

  await page.getByRole('button', { name: 'Add Maintenance' }).click();
  await expect(page.getByRole('dialog', { name: 'Add Maintenance' })).toBeVisible();

  await page.getByLabel('Schedule Name').fill('Annual brake inspection');
  await page.getByLabel('Unit #').click();
  await page.getByRole('option', { name: '1021' }).click();
  await page.getByLabel(/Current Frequency/).fill('20000');
  await page.getByLabel('Maintenance Frequency').fill('25000');

  await page.getByRole('button', { name: 'Create' }).click();
  await expect(page.getByText('Annual brake inspection created')).toBeVisible();
  await expect(page.getByRole('dialog', { name: 'Add Maintenance' })).toBeHidden();

  await page.getByRole('tab', { name: 'Due' }).click();
  await page.waitForURL(/\/maintenance\/due/);

  await page.getByRole('button', { name: 'Actions for unit 1021', exact: true }).click();
  await page.getByRole('menuitem', { name: 'Mark as Complete' }).click();

  const modal = page.getByRole('dialog', { name: 'MARK MAINTENANCE AS COMPLETE' });
  await expect(modal).toBeVisible();

  await modal.getByLabel('Invoice #').fill('INV-9001');
  await modal.getByLabel('Vendor Name').fill('Dallas Truck Service');
  await modal.getByLabel('Cost').fill('420.50');

  await modal.locator('input[type="file"]').setInputFiles({
    name: 'invoice.pdf',
    mimeType: 'application/pdf',
    buffer: Buffer.from('%PDF-1.4 mock invoice'),
  });
  await expect(modal.getByText('invoice.pdf')).toBeVisible();

  await modal.getByRole('button', { name: 'Mark as Complete' }).click();
  await expect(page.getByText('Maintenance for unit 1021 marked as complete')).toBeVisible();
});
