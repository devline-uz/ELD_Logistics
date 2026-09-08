import type { ReactNode } from 'react';

export interface CardProps {
  title?: ReactNode;
  actions?: ReactNode;
  children: ReactNode;
  footer?: ReactNode;
  className?: string;
}

/** Sarlavha + amal + kontent konteyneri (fe-design-system §6). */
export function Card({ title, actions, children, footer, className }: CardProps) {
  return (
    <div className={`rounded-lg border border-stroke bg-surface shadow-card ${className ?? ''}`}>
      {title || actions ? (
        <div className="flex items-center justify-between gap-4 border-b border-stroke px-5 py-4">
          {title ? (
            <h3 className="text-body-lg font-semibold text-neutral-900">{title}</h3>
          ) : (
            <span />
          )}
          {actions ? <div className="flex items-center gap-2">{actions}</div> : null}
        </div>
      ) : null}
      <div className="px-5 py-4">{children}</div>
      {footer ? <div className="border-t border-stroke px-5 py-4">{footer}</div> : null}
    </div>
  );
}

export default Card;
