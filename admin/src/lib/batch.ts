/**
 * `batchSettled` — kalitlar ro'yxatini `concurrency` talik to'plamlarga bo'lib,
 * har to'plamni ketma-ket kutib bajaradi (TD2).
 *
 * Nima uchun `Promise.all` emas: bir vaqtning o'zida ochiq so'rovlar soni
 * qat'iy cheklanishi kerak (F95 — HOS batch'lari uchun ≤ 6). `allSettled`
 * ishlatiladi, chunki bitta element yiqilsa butun batch yiqilmasligi shart —
 * natija xaritasida shu kalit `undefined` bo'lib qoladi.
 *
 * Kalitlar takrorlanmas deb hisoblanadi (chaqiruvchi `driverId` yoki `date`
 * beradi); takror kalit bo'lsa oxirgi natija qoladi.
 */
export async function batchSettled<K extends string, R>(
  keys: readonly K[],
  fn: (key: K) => Promise<R>,
  concurrency: number,
): Promise<Record<K, R | undefined>> {
  const result = {} as Record<K, R | undefined>;
  for (let i = 0; i < keys.length; i += concurrency) {
    const chunk = keys.slice(i, i + concurrency);
    const settled = await Promise.allSettled(chunk.map((key) => fn(key)));
    chunk.forEach((key, idx) => {
      const outcome = settled[idx];
      result[key] = outcome?.status === 'fulfilled' ? outcome.value : undefined;
    });
  }
  return result;
}
