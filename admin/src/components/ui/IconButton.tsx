import { forwardRef } from 'react';
import type { ButtonHTMLAttributes } from 'react';
import { Loader2 } from 'lucide-react';
import type { LucideIcon } from 'lucide-react';

import { cn } from './cn';
import { Icon } from './Icon';

export type IconButtonVariant = 'primary' | 'secondary' | 'ghost' | 'danger';
export type IconButtonSize = 'sm' | 'md' | 'lg';

export interface IconButtonProps extends Omit<
  ButtonHTMLAttributes<HTMLButtonElement>,
  'aria-label'
> {
  icon: LucideIcon;
  /** Matnsiz tugma hech qachon label'siz emas (fe-a11y §2). */
  'aria-label': string;
  variant?: IconButtonVariant;
  size?: IconButtonSize;
  loading?: boolean;
}

const VARIANT_CLASSES: Record<IconButtonVariant, string> = {
  primary:
    'bg-primary text-white hover:bg-primary-hover disabled:bg-neutral-300 disabled:text-neutral-500',
  secondary:
    'bg-surface text-neutral-700 border border-stroke hover:bg-surface-muted disabled:text-neutral-400',
  ghost: 'bg-transparent text-neutral-600 hover:bg-surface-muted disabled:text-neutral-400',
  danger:
    'bg-error-base text-white hover:bg-error-dark disabled:bg-neutral-300 disabled:text-neutral-500',
};

const SIZE_CLASSES: Record<IconButtonSize, string> = {
  sm: 'h-8 w-8 rounded-md',
  md: 'h-10 w-10 rounded-md',
  lg: 'h-12 w-12 rounded-md',
};

const ICON_SIZE: Record<IconButtonSize, 16 | 20 | 24> = {
  sm: 16,
  md: 20,
  lg: 24,
};

/**
 * Kvadrat, faqat ikonkali tugma. `aria-label` majburiy.
 */
export const IconButton = forwardRef<HTMLButtonElement, IconButtonProps>(function IconButton(
  {
    icon,
    variant = 'ghost',
    size = 'md',
    loading = false,
    disabled,
    className,
    type = 'button',
    ...rest
  },
  ref,
) {
  const isDisabled = disabled ?? loading;

  return (
    <button
      ref={ref}
      type={type}
      disabled={isDisabled}
      aria-busy={loading || undefined}
      className={cn(
        'inline-flex items-center justify-center transition-colors',
        'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2',
        'disabled:cursor-not-allowed',
        VARIANT_CLASSES[variant],
        SIZE_CLASSES[size],
        className,
      )}
      {...rest}
    >
      <Icon
        icon={loading ? Loader2 : icon}
        size={ICON_SIZE[size]}
        className={cn(loading && 'animate-spin')}
      />
    </button>
  );
});

export default IconButton;
