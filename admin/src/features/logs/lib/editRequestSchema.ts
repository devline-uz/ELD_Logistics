/**
 * `SendEditRequestPanel` forma sxemasi (7.4.3(b), F100).
 *
 * `From`/`To` maydonlari `<input type="datetime-local">` — foydalanuvchiga
 * **kompaniya home-terminal zonasida** ko'rsatiladi/kiritiladi, submit
 * vaqtida UTC ISO'ga aylantiriladi (`fromZonedTime`, `date-fns-tz`).
 */
import { fromZonedTime, toZonedTime } from 'date-fns-tz';
import { format } from 'date-fns';
import { z } from 'zod';

/** `Note *` — TZ 7.4.3(b): majburiy, ≤ 60 belgi. */
export const editRequestSchema = z
  .object({
    status: z.enum(['OFF', 'SB', 'DR', 'ON']),
    special: z.enum(['none', 'pc', 'ym']),
    from: z.string().min(1, 'required'),
    to: z.string().min(1, 'required'),
    note: z.string().trim().min(1, 'required').max(60, 'max 60 characters'),
  })
  .refine((values) => new Date(values.to) > new Date(values.from), {
    message: 'to must be after from',
    path: ['to'],
  });

export type EditRequestFormValues = z.infer<typeof editRequestSchema>;

const DATETIME_LOCAL_FORMAT = "yyyy-MM-dd'T'HH:mm";

/** ISO UTC instant → `datetime-local` qiymati (kompaniya zonasida). */
export function isoToLocalInput(iso: string, timezone: string): string {
  return format(toZonedTime(iso, timezone), DATETIME_LOCAL_FORMAT);
}

/** `datetime-local` qiymati (kompaniya zonasida) → ISO UTC instant. */
export function localInputToIso(value: string, timezone: string): string {
  return fromZonedTime(value, timezone).toISOString();
}
