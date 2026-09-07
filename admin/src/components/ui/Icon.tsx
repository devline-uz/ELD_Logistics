import { forwardRef } from 'react';
import type { SVGAttributes } from 'react';
import type { LucideIcon } from 'lucide-react';

import { cn } from './cn';

export type IconSize = 12 | 14 | 16 | 20 | 24 | 32;

export interface IconProps extends Omit<SVGAttributes<SVGSVGElement>, 'width' | 'height'> {
  /** `lucide-react` ikonka komponenti (tree-shaking uchun alohida import). */
  icon: LucideIcon;
  /** Piksel o'lchami (kvadrat). Default — 20 (fe-design-system §5: 24x24 grid). */
  size?: IconSize;
  /**
   * Ikonka mustaqil ma'no tashisa (masalan tugmada matn yo'q) — shu yerga
   * ko'rinadigan nom bering. Berilmasa ikonka dekorativ deb hisoblanadi va
   * skrin-rider'dan yashiriladi (`aria-hidden`).
   */
  label?: string;
  className?: string;
}

/**
 * Barcha `lucide-react` ikonkalari shu wrapper orqali ishlatiladi — bir xil
 * o'lcham/stroke-width va a11y xatti-harakatini kafolatlash uchun.
 */
export const Icon = forwardRef<SVGSVGElement, IconProps>(function Icon(
  { icon: LucideIconComponent, size = 20, label, className, ...rest },
  ref,
) {
  const a11yProps = label
    ? ({ role: 'img', 'aria-label': label } as const)
    : ({ 'aria-hidden': true } as const);

  return (
    <LucideIconComponent
      ref={ref}
      width={size}
      height={size}
      strokeWidth={1.5}
      className={cn('shrink-0', className)}
      {...a11yProps}
      {...rest}
    />
  );
});

export default Icon;
