/**
 * Oqim 7 — Report: Distance by Region → export job → download (§14.4.7).
 *
 * `admin` profili default `regulation_profile: us_fmcsa` bilan keladi
 * (`src/mocks/handlers/company.ts` fixture), shuning uchun ekran sarlavhasi
 * "IFTA Report" (D32) — 9.8 testi buni "generic" bilan solishtiradi.
 */
import { adminTest as test, expect } from './fixtures';

test('generate a distance report export job and download the file', async ({ page }) => {
  await page.goto('/reports/distance-by-region');
  await expect(page.getByRole('heading', { name: 'IFTA Report' })).toBeVisible();

  await page.getByRole('button', { name: 'Generate' }).click();
  const modal = page.getByRole('dialog', { name: 'Generate Distance by Region Report' });
  await expect(modal).toBeVisible();

  // "Regions only" — Units ko'p-tanlov maydonini chetlab o'tadi (tezroq oqim).
  await modal.getByRole('combobox', { name: 'GET BY' }).click();
  await page.getByRole('option', { name: 'Regions only' }).click();

  await modal.getByRole('button', { name: 'Generate' }).click();

  await expect(modal.getByText('Your file is ready.')).toBeVisible();

  // Yuklab olish havolasi haqiqiy (mavjud bo'lmagan) tashqi hostga ketadi —
  // `window.open` yangi tab/popup ochadi, MSW worker esa faqat joriy
  // origin'dan chiqadigan so'rovlarni ushlab qoladi (cross-origin **top-level
  // navigatsiya** emas). Shu sabab popup's navigatsiyasi kontekst darajasida
  // ushlanadi — haqiqiy tarmoqqa chiqish yo'q (F226).
  await page.context().route('https://storage.example.com/**', async (route) => {
    await route.fulfill({ status: 200, contentType: 'text/plain', body: 'mock xlsx content' });
  });

  const popupPromise = page.waitForEvent('popup');
  await modal.getByRole('button', { name: 'Download' }).click();
  const popup = await popupPromise;
  await expect.poll(() => popup.url()).toContain('storage.example.com');
});
