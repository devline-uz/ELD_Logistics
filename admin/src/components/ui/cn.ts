/**
 * Yengil classname birlashtiruvchi (clsx o'rniga — loyihada o'rnatilmagan).
 * Faqat `src/components/ui/**` ichida ishlatiladi.
 */
export type ClassValue = string | number | null | boolean | undefined | ClassValue[];

export function cn(...inputs: ClassValue[]): string {
  const out: string[] = [];

  const walk = (value: ClassValue): void => {
    if (!value) return;
    if (Array.isArray(value)) {
      value.forEach(walk);
      return;
    }
    out.push(String(value));
  };

  inputs.forEach(walk);
  return out.join(' ');
}
