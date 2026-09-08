/**
 * Xarita ma'lumotining **matnli/jadval ekvivalenti** (F171, TZ §14.2 a11y).
 *
 * Xarita hech qachon yagona ma'lumot manbai bo'lmaydi: xarita ko'rsatayotgan
 * har bir nuqta/segment shu komponent orqali haqiqiy `<table>` sifatida ham
 * beriladi.
 *
 * Ko'rish rejimi:
 * - **Default** — jadval `sr-only` (vizual ko'rinmaydi, lekin skrinrider
 *   uchun DOM'da to'liq mavjud, ya'ni a11y ekvivalenti har doim bor).
 * - **"Show as table"** tugmasi — jadvalni ko'zga ham ko'rinadigan qiladi
 *   (klaviatura foydalanuvchisi va past ko'rish uchun).
 *
 * Xarita bilan bog'lash: `id` props'i beriladi va xaritaga
 * `ariaDescribedBy={id}` uzatiladi (`MapCanvas`).
 */
import { useState, type ReactNode } from 'react';
import { useTranslation } from 'react-i18next';

export interface MapDataTableColumn<TRow> {
  /** React `key` va ustunni ajratish uchun barqaror identifikator. */
  key: string;
  header: string;
  cell: (row: TRow, index: number) => ReactNode;
}

export interface MapDataTableProps<TRow> {
  /** Xarita `aria-describedby` orqali shu `id`ga ishora qiladi. */
  id?: string;
  /** Jadval sarlavhasi (`<caption>`) — nima ko'rsatilayotganini aytadi. */
  caption: string;
  columns: MapDataTableColumn<TRow>[];
  rows: TRow[];
  getRowKey: (row: TRow, index: number) => string;
  /** Nuqta/segment bo'lmaganda ko'rsatiladigan matn. */
  emptyLabel: string;
  className?: string;
}

export function MapDataTable<TRow>({
  id,
  caption,
  columns,
  rows,
  getRowKey,
  emptyLabel,
  className,
}: MapDataTableProps<TRow>) {
  const { t } = useTranslation();
  const [visible, setVisible] = useState(false);

  return (
    <section id={id} aria-label={caption} className={className}>
      {/*
        Jadval **har doim** DOM'da (sr-only) — shuning uchun bu tugma
        disclosure emas, faqat vizual ko'rinish almashtirgichi: `aria-expanded`
        skrinriderga "kontent yopiq" deb yolg'on aytardi, holbuki u o'qiy
        oladi. To'g'ri semantika — `aria-pressed` (toggle tugma).
      */}
      <button
        type="button"
        aria-pressed={visible}
        onClick={() => setVisible((open) => !open)}
        className="rounded-md text-body-sm font-medium text-primary hover:underline focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary"
      >
        {visible ? t('map.dataTable.hide') : t('map.dataTable.show')}
      </button>

      <div className={visible ? 'mt-2 overflow-x-auto' : 'sr-only'}>
        <table className="w-full border-collapse text-body-sm">
          <caption className="sr-only">{caption}</caption>
          <thead>
            <tr>
              {columns.map((column) => (
                <th
                  key={column.key}
                  scope="col"
                  className="border-b border-stroke px-2 py-1 text-start font-semibold text-neutral-700"
                >
                  {column.header}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {rows.length === 0 ? (
              <tr>
                <td colSpan={columns.length} className="px-2 py-2 text-neutral-500">
                  {emptyLabel}
                </td>
              </tr>
            ) : (
              rows.map((row, index) => (
                <tr key={getRowKey(row, index)}>
                  {columns.map((column) => (
                    <td
                      key={column.key}
                      className="border-b border-stroke px-2 py-1 align-top text-neutral-800"
                    >
                      {column.cell(row, index)}
                    </td>
                  ))}
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </section>
  );
}

export default MapDataTable;
