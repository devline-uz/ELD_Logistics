/**
 * Xarita animatsiyasi va `prefers-reduced-motion` (F166).
 *
 * Alohida modul: bu funksiyalar `MapCanvas.tsx` da turganida
 * `react-refresh/only-export-components` ogohlantirishi chiqar edi va qatlam
 * hook'lari (`useLiveUnitsLayer`, `useTripPolylineLayer`) komponent modulini
 * import qilishga majbur bo'lardi.
 */
export function prefersReducedMotion(): boolean {
  if (typeof window === 'undefined' || typeof window.matchMedia !== 'function') return false;
  return window.matchMedia('(prefers-reduced-motion: reduce)').matches;
}

/** Marker/kamera animatsiyasi davomiyligi — reduced-motion'da 0 (F166, fe-map jadvali). */
export function easeDurationMs(): number {
  return prefersReducedMotion() ? 0 : 500;
}
