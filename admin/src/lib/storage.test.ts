/**
 * `resolveStorageUrl` — URL injection himoyasi (fe-security §2).
 *
 * Kalit backenddan keladi va `<img src>` ga tushadi, shuning uchun xavfli
 * sxemalar va baza URL'idan chiqib ketuvchi yo'llar rad etiladi.
 */
import { describe, expect, it } from 'vitest';

import { resolveStorageUrl } from './storage';

describe('resolveStorageUrl', () => {
  it('returns undefined for an empty key', () => {
    expect(resolveStorageUrl(undefined)).toBeUndefined();
    expect(resolveStorageUrl('')).toBeUndefined();
  });

  it('rejects dangerous schemes', () => {
    expect(resolveStorageUrl('javascript:alert(1)')).toBeUndefined();
    expect(resolveStorageUrl('data:text/html,<script>alert(1)</script>')).toBeUndefined();
    expect(resolveStorageUrl('blob:https://evil.example/abc')).toBeUndefined();
  });

  it('rejects plain http absolute URLs (mixed content)', () => {
    expect(resolveStorageUrl('http://storage.example/a.png')).toBeUndefined();
  });

  it('keeps https absolute URLs', () => {
    expect(resolveStorageUrl('https://storage.example/a.png')).toBe(
      'https://storage.example/a.png',
    );
  });

  it('rejects relative keys that traverse out of the base URL', () => {
    expect(resolveStorageUrl('c1/../../etc/passwd')).toBeUndefined();
  });
});
