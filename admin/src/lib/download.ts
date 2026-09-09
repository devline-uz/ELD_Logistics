/**
 * Blob → dasturiy `<a download>` (fe-api §8 «Yuklab olish»).
 *
 * PDF/eksport javoblari `Authorization` header talab qiladi → oddiy `<a href>`
 * ishlamaydi: javob `blob` sifatida olinadi va shu yerda saqlanadi.
 *
 * `URL.revokeObjectURL` **`finally`** blokida — anchor yaratish yoki `click()`
 * exception tashlasa ham object URL bo'shatiladi (3-bosqich nuqsoni: leak).
 */
export function saveBlob(blob: Blob, filename: string): void {
  const objectUrl = URL.createObjectURL(blob);
  try {
    const anchor = document.createElement('a');
    anchor.href = objectUrl;
    anchor.download = filename;
    document.body.appendChild(anchor);
    anchor.click();
    anchor.remove();
  } finally {
    URL.revokeObjectURL(objectUrl);
  }
}

/**
 * Server xato sahifasi (`text/html`) `.pdf` nomi bilan saqlanib qolmasligi
 * uchun javob turini tekshiradi (TD12). `fetch` javobidan olingan `Blob`
 * ning `type` maydoni `Content-Type` ni saqlaydi.
 */
export class UnexpectedFileTypeError extends Error {
  readonly expectedType: string;
  readonly receivedType: string;

  constructor(expectedType: string, receivedType: string) {
    super(`Expected ${expectedType} response, received ${receivedType || 'unknown type'}`);
    this.name = 'UnexpectedFileTypeError';
    this.expectedType = expectedType;
    this.receivedType = receivedType;
  }
}

/** `blob.type` kutilgan MIME turiga mos bo'lmasa `UnexpectedFileTypeError` tashlaydi. */
export function assertBlobType(blob: Blob, expectedType: string): Blob {
  const received = (blob.type ?? '').split(';')[0]?.trim().toLowerCase() ?? '';
  if (received !== expectedType) {
    throw new UnexpectedFileTypeError(expectedType, received);
  }
  return blob;
}
