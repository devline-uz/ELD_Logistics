export type SkeletonVariant = 'text' | 'line' | 'card' | 'table-row' | 'map';

export interface SkeletonProps {
  variant?: SkeletonVariant;
  /** Nechta blok chizilsin (masalan jadval uchun 5 satr). */
  count?: number;
  className?: string;
}

const VARIANT_CLASSES: Record<SkeletonVariant, string> = {
  text: 'h-4 w-full rounded-sm',
  line: 'h-2 w-full rounded-full',
  card: 'h-32 w-full rounded-lg',
  'table-row': 'h-10 w-full rounded-sm',
  map: 'h-64 w-full rounded-lg',
};

/**
 * `prefers-reduced-motion` da animatsiya yo'q (`motion-safe:` variant),
 * `aria-hidden` — skrin-rider o'qimaydi (fe-a11y §4, fe-screens §6).
 */
export function Skeleton({ variant = 'text', count = 1, className }: SkeletonProps) {
  return (
    <div className="flex w-full flex-col gap-2" aria-hidden="true">
      {Array.from({ length: count }, (_, index) => (
        <div
          key={index}
          className={`motion-safe:animate-pulse bg-neutral-100 ${VARIANT_CLASSES[variant]} ${className ?? ''}`}
        />
      ))}
    </div>
  );
}

export default Skeleton;
