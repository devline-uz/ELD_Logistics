/**
 * Xarita uslubi (style) tayyor bo'lganda callback'ni **bir marta** ishga
 * tushiradi va tinglovchini albatta olib tashlaydi.
 *
 * Nega kerak: `map.once('load', …)` hech qachon `off` qilinmasa, effekt har
 * qayta ishga tushganda yuklanmagan xaritada handler'lar to'planadi. Bundan
 * tashqari `isStyleLoaded()` `load` hodisasidan **keyin ham** vaqtincha
 * `false` qaytarishi mumkin — bunda `once('load')` boshqa otilmaydi va
 * ma'lumot umuman qo'llanilmay qolardi. Shuning uchun `load` bilan birga
 * `styledata` ham tinglanadi va tayyorlik `isStyleLoaded() || loaded()`
 * bo'yicha tekshiriladi.
 *
 * @returns bekor qilish funksiyasi — effekt cleanup'ida chaqiriladi.
 */
import type { Map as MapLibreMap } from 'maplibre-gl';

export function whenStyleReady(map: MapLibreMap, run: (map: MapLibreMap) => void): () => void {
  if (map.isStyleLoaded()) {
    run(map);
    return () => undefined;
  }

  let cancelled = false;

  const handler = () => {
    if (cancelled) return;
    if (!map.isStyleLoaded() && !map.loaded()) return;
    detach();
    run(map);
  };

  const detach = () => {
    map.off('load', handler);
    map.off('styledata', handler);
  };

  map.on('load', handler);
  map.on('styledata', handler);

  return () => {
    cancelled = true;
    detach();
  };
}
