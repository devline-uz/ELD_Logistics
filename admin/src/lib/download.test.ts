import { describe, expect, it, vi, afterEach } from 'vitest';

import { assertBlobType, saveBlob, UnexpectedFileTypeError } from './download';

const createObjectURL = vi.fn(() => 'blob:mock-url');
const revokeObjectURL = vi.fn();

vi.stubGlobal('URL', { ...URL, createObjectURL, revokeObjectURL });

afterEach(() => {
  createObjectURL.mockClear();
  revokeObjectURL.mockClear();
});

describe('saveBlob', () => {
  it('anchor yaratadi, download nomini qoyadi va bosadi', () => {
    const clicked: string[] = [];
    const click = vi.spyOn(HTMLAnchorElement.prototype, 'click').mockImplementation(function (
      this: HTMLAnchorElement,
    ) {
      clicked.push(`${this.href}|${this.download}`);
    });

    saveBlob(new Blob(['a']), 'units.csv');

    expect(clicked).toEqual(['blob:mock-url|units.csv']);
    expect(revokeObjectURL).toHaveBeenCalledWith('blob:mock-url');
    expect(document.querySelector('a[download]')).toBeNull();
    click.mockRestore();
  });

  it('click() xato tashlasa ham object URL bosatiladi (leak yoq)', () => {
    const click = vi.spyOn(HTMLAnchorElement.prototype, 'click').mockImplementation(() => {
      throw new Error('boom');
    });

    expect(() => saveBlob(new Blob(['a']), 'x.pdf')).toThrow('boom');
    expect(revokeObjectURL).toHaveBeenCalledWith('blob:mock-url');
    click.mockRestore();
  });
});

describe('assertBlobType', () => {
  it('mos MIME turida bir xil blobni qaytaradi', () => {
    const blob = new Blob(['%PDF'], { type: 'application/pdf' });
    expect(assertBlobType(blob, 'application/pdf')).toBe(blob);
  });

  it('charset bilan kelgan Content-Type ni ham qabul qiladi', () => {
    const blob = new Blob(['a,b'], { type: 'text/csv; charset=utf-8' });
    expect(assertBlobType(blob, 'text/csv')).toBe(blob);
  });

  it('HTML xato sahifasida UnexpectedFileTypeError tashlaydi', () => {
    const blob = new Blob(['<html>500</html>'], { type: 'text/html' });
    expect(() => assertBlobType(blob, 'application/pdf')).toThrow(UnexpectedFileTypeError);
  });
});
