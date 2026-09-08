/**
 * View ekranlaridagi `label → value` ro'yxati (§7.6 View bloklari).
 * Domenni bilmaydi — faqat tayyor matnlar.
 */
import type { ReactNode } from 'react';

export interface FieldListItem {
  label: string;
  value: ReactNode;
}

export function FieldList({ items }: { items: FieldListItem[] }) {
  return (
    <dl className="grid grid-cols-2 gap-x-6 gap-y-4">
      {items.map((item) => (
        <div key={item.label} className="flex flex-col gap-1">
          <dt className="text-body-sm text-neutral-500">{item.label}</dt>
          <dd className="text-body text-neutral-900">{item.value}</dd>
        </div>
      ))}
    </dl>
  );
}

export default FieldList;
