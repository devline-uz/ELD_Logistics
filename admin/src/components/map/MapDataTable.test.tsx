/**
 * MapDataTable — a11y: jadval **har doim** DOM'da (F171 ekvivalenti), tugma
 * esa faqat vizual ko'rinishni almashtiradi (`aria-pressed`, `aria-expanded`
 * emas — aks holda skrinriderga "yopiq" deb yolg'on aytilardi).
 */
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it } from 'vitest';

import '@/app/i18n';

import { MapDataTable } from './MapDataTable';

const rows = [{ id: 'u1', unitNumber: '1021' }];

function renderTable() {
  render(
    <MapDataTable
      caption="Units on the map"
      columns={[{ key: 'unit', header: 'Unit #', cell: (row) => row.unitNumber }]}
      rows={rows}
      getRowKey={(row) => row.id}
      emptyLabel="No units"
    />,
  );
}

describe('MapDataTable', () => {
  it('keeps the table in the DOM and toggles only its visibility', async () => {
    const user = userEvent.setup();
    renderTable();

    // Skrinrider uchun ma'lumot boshidanoq mavjud.
    expect(screen.getByRole('table')).toBeInTheDocument();
    expect(screen.getByText('1021')).toBeInTheDocument();

    const toggle = screen.getByRole('button');
    expect(toggle).toHaveAttribute('aria-pressed', 'false');
    expect(toggle).not.toHaveAttribute('aria-expanded');

    await user.click(toggle);

    expect(toggle).toHaveAttribute('aria-pressed', 'true');
    expect(screen.getByRole('table')).toBeInTheDocument();
  });
});
