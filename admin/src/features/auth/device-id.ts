/**
 * `device_id` — login so'rovi identifikatori (fe-screens §7.1.1).
 *
 * Bu **token emas**, shuning uchun `localStorage`da saqlash xavfsizlik
 * qoidasini (fe-security §4) buzmaydi — faqat "shu qurilma" ekanini
 * bildiruvchi tasodifiy identifikator. `Remember this device` belgilanmasa
 * har login uchun vaqtinchalik (saqlanmaydigan) qiymat ishlatiladi.
 */
const DEVICE_ID_KEY = 'eld.device_id';

function randomId(): string {
  if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') {
    return crypto.randomUUID();
  }
  return `${Date.now().toString(16)}-${Math.random().toString(16).slice(2, 14)}`;
}

/** Saqlangan `device_id` (bor bo'lsa) — `Remember this device` bosilganda ishlatiladi. */
export function getRememberedDeviceId(): string | null {
  try {
    return localStorage.getItem(DEVICE_ID_KEY);
  } catch {
    return null;
  }
}

function storeDeviceId(id: string): void {
  try {
    localStorage.setItem(DEVICE_ID_KEY, id);
  } catch {
    // Saqlash imkoni bo'lmasa — vaqtinchalik id bilan davom etiladi.
  }
}

/**
 * Login so'rovida yuboriladigan `device_id` ni tanlaydi.
 * `remember` bo'lsa — saqlangan (yoki yangi yaratilib saqlangan) qiymat;
 * bo'lmasa — bir martalik, saqlanmaydigan qiymat.
 */
export function resolveDeviceId(remember: boolean): string {
  if (!remember) return randomId();

  const existing = getRememberedDeviceId();
  if (existing) return existing;

  const created = randomId();
  storeDeviceId(created);
  return created;
}
