import { describe, expect, it, vi } from 'vitest';

import { batchSettled } from './batch';

describe('batchSettled', () => {
  it('bosh royxat uchun bosh natija qaytaradi', async () => {
    const fn = vi.fn();
    await expect(batchSettled([], fn, 3)).resolves.toEqual({});
    expect(fn).not.toHaveBeenCalled();
  });

  it('concurrency chegarasidan oshmaydi va toplamlarni ketma-ket kutadi', async () => {
    let open = 0;
    let peak = 0;
    const keys = ['a', 'b', 'c', 'd', 'e', 'f', 'g'];

    const result = await batchSettled(
      keys,
      async (key) => {
        open += 1;
        peak = Math.max(peak, open);
        await Promise.resolve();
        open -= 1;
        return key.toUpperCase();
      },
      3,
    );

    expect(peak).toBeLessThanOrEqual(3);
    expect(result).toEqual({ a: 'A', b: 'B', c: 'C', d: 'D', e: 'E', f: 'F', g: 'G' });
  });

  it('bitta element yiqilsa faqat oshanga undefined qoyadi', async () => {
    const result = await batchSettled(
      ['ok', 'bad'],
      async (key) => {
        await Promise.resolve();
        if (key === 'bad') throw new Error('boom');
        return 1;
      },
      2,
    );
    expect(result).toEqual({ ok: 1, bad: undefined });
  });
});
