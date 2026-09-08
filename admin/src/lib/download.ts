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
