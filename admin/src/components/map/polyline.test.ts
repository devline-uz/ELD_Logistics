import { describe, expect, it } from 'vitest';

import { decodePolyline } from './polyline';

describe('decodePolyline', () => {
  it("Google encoded polyline namunasini to'g'ri dekodlaydi", () => {
    // Google Maps Encoded Polyline Algorithm hujjatidagi standart misol.
    const coordinates = decodePolyline('_p~iF~ps|U_ulLnnqC_mqNvxq`@');

    expect(coordinates).toEqual([
      [-120.2, 38.5],
      [-120.95, 40.7],
      [-126.453, 43.252],
    ]);
  });

  it("bo'sh/undefined kirishda bo'sh massiv qaytaradi", () => {
    expect(decodePolyline('')).toEqual([]);
    expect(decodePolyline(undefined)).toEqual([]);
    expect(decodePolyline(null)).toEqual([]);
  });
});
