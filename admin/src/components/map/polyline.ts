/**
 * Google encoded polyline (precision 5) dekoderi — `fe-map` skill, Trip
 * polyline bo'limi. Backend `Trip.polyline`/`Directions.polyline` shu formatda
 * qaytaradi (`/trips/{id}?include_polyline=true`, `/routes/{id}/directions`).
 *
 * Kutubxona qo'shilmaydi (F3 ruhida — faqat MapLibre ustiga qo'lda wrapper),
 * algoritm ~30 qatorlik standart dekodlash.
 */

/** `[lng, lat]` juftliklari — GeoJSON `LineString` koordinatalari tartibida. */
export type LngLatTuple = [number, number];

export function decodePolyline(encoded: string | undefined | null): LngLatTuple[] {
  if (!encoded) return [];

  const coordinates: LngLatTuple[] = [];
  let index = 0;
  let lat = 0;
  let lng = 0;

  while (index < encoded.length) {
    let result = 0;
    let shift = 0;
    let byte: number;

    do {
      byte = encoded.charCodeAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);
    lat += result & 1 ? ~(result >> 1) : result >> 1;

    result = 0;
    shift = 0;
    do {
      byte = encoded.charCodeAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);
    lng += result & 1 ? ~(result >> 1) : result >> 1;

    coordinates.push([lng / 1e5, lat / 1e5]);
  }

  return coordinates;
}
