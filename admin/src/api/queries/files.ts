/**
 * `POST /files/presign` — fayl yuklashning yagona kirish nuqtasi (fe-api §8).
 *
 * `FileUpload` komponentining `onPresign` propiga to'g'ridan-to'g'ri beriladi.
 * 5-bosqichda DVIR (repair invoice) va Maintenance (`Mark as Complete` invoice)
 * ikkalasi ham shu endpointni ishlatadi, shuning uchun yordamchi modul ichida
 * emas, umumiy qatlamda turadi — parallel agentlar yozgan ikki nusxa shu yerga
 * birlashtirildi.
 */
import { api } from '@/api/client';
import type { PresignResponse } from '@/api/types';
import type { FileUploadKind } from '@/components/form/FileUpload';

export interface PresignInput {
  kind: FileUploadKind;
  content_type: string;
  size_bytes: number;
  filename?: string;
}

export async function presignFile(input: PresignInput): Promise<PresignResponse> {
  const { data } = await api.POST('/files/presign', { body: input });
  return data?.data ?? {};
}
