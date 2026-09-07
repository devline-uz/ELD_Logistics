import { useEffect } from 'react';
import type { FieldValues, UseFormReturn } from 'react-hook-form';

/**
 * Modal/forma ochilganda (yoki tahrirlanayotgan obyekt almashganda)
 * `react-hook-form` qiymatlarini qayta o'rnatadi.
 *
 * 9 ta forma faylida bir xil `useEffect([open, entity]) { form.reset(...) }`
 * naqshi takrorlangan edi (har birida `react-hooks/exhaustive-deps` uchun
 * `eslint-disable-next-line`) — bosqich 2 ko'rigi (dublikat topilmasi).
 * Endi disable faqat shu faylda bir marta kerak.
 *
 * @param form `useForm()` natijasi
 * @param open Modal ochiqmi (`false` bo'lsa reset qilinmaydi)
 * @param getValues Reset qilinadigan qiymatlarni qaytaruvchi funksiya
 *   (har render chaqiriladi, lekin faqat `open` true va `deps` o'zgarganda
 *   qo'llaniladi)
 * @param deps `open`dan tashqari qo'shimcha bog'liqliklar (masalan,
 *   tahrirlanayotgan obyekt) — o'zgarganda reset qayta ishga tushadi
 * @param onReset Reset bilan bir vaqtda bajariladigan qo'shimcha amal
 *   (masalan, forma xatosini tozalash)
 */
export function useResetFormOnOpen<TFieldValues extends FieldValues>(
  form: UseFormReturn<TFieldValues>,
  open: boolean,
  getValues: () => TFieldValues,
  deps: readonly unknown[] = [],
  onReset?: () => void,
): void {
  useEffect(() => {
    if (open) {
      form.reset(getValues());
      onReset?.();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, ...deps]);
}
