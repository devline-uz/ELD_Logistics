export interface AvatarProps {
  /** Initsiallar shundan hisoblanadi va `alt`/`aria-label` sifatida ishlatiladi. */
  name: string;
  src?: string;
  size?: 'sm' | 'md' | 'lg';
}

const SIZE_CLASSES: Record<NonNullable<AvatarProps['size']>, string> = {
  sm: 'h-8 w-8 text-body-xs',
  md: 'h-10 w-10 text-body-sm',
  lg: 'h-12 w-12 text-body',
};

function getInitials(name: string): string {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) {
    return '';
  }
  if (parts.length === 1) {
    return parts[0]!.slice(0, 2).toUpperCase();
  }
  return `${parts[0]![0]}${parts[parts.length - 1]![0]}`.toUpperCase();
}

/** Rasm bo'lmasa initsiallar bilan fallback (fe-design-system §6). */
export function Avatar({ name, src, size = 'md' }: AvatarProps) {
  if (src) {
    return (
      <img
        src={src}
        alt={name}
        className={`inline-block rounded-full object-cover ${SIZE_CLASSES[size]}`}
      />
    );
  }

  return (
    <span
      role="img"
      aria-label={name}
      className={`inline-flex items-center justify-center rounded-full bg-neutral-200 font-semibold text-neutral-700 ${SIZE_CLASSES[size]}`}
    >
      <span aria-hidden="true">{getInitials(name)}</span>
    </span>
  );
}

export default Avatar;
