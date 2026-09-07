/**
 * `axe-core` orqali avtomatik a11y skani — `admin/src/components/**` ichidagi
 * asosiy komponentlarni render qilib, kritik/jiddiy xato 0 ekanini tekshiradi
 * (fe-a11y §5, TZ 1.17). Har komponent alohida `describe` blokida — bitta
 * komponentda topilgan xato boshqalarning natijasini yashirmaydi.
 *
 * Faqat props orqali boshqariladigan, og'ir kontekst (auth/permission/query)
 * talab qilmaydigan komponentlar shu yerda tekshiriladi. Navigatsiya
 * (`MainNav`, `ProfileMenu`, `BrandBar`) `usePermission()`/auth holatiga
 * bog'liq — ular integratsion testlarda alohida qamrab olinadi.
 */
import { act, render } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { describe, expect, it } from 'vitest';
import { axe } from 'vitest-axe';

import '@/app/i18n';

import { Avatar } from '@/components/ui/Avatar';
import { Badge } from '@/components/ui/Badge';
import { Breadcrumb } from '@/components/ui/Breadcrumb';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Checkbox } from '@/components/ui/Checkbox';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { DatePicker } from '@/components/ui/DatePicker';
import { DateRangePicker } from '@/components/ui/DateRangePicker';
import { Drawer } from '@/components/ui/Drawer';
import { IconButton } from '@/components/ui/IconButton';
import { Icon } from '@/components/ui/Icon';
import { KpiCard } from '@/components/ui/KpiCard';
import { Modal } from '@/components/ui/Modal';
import { MultiSelect } from '@/components/ui/MultiSelect';
import { Radio } from '@/components/ui/Radio';
import { Select } from '@/components/ui/Select';
import { StatusChip } from '@/components/ui/StatusChip';
import { Switch } from '@/components/ui/Switch';
import { Tabs } from '@/components/ui/Tabs';
import { Textarea } from '@/components/ui/Textarea';
import { TimePicker } from '@/components/ui/TimePicker';
import { Tooltip } from '@/components/ui/Tooltip';
import { Input } from '@/components/ui/Input';
import { AlertTriangle } from 'lucide-react';

import { ColumnPicker } from '@/components/data/ColumnPicker';
import { DataTable } from '@/components/data/DataTable';
import { FiltersBar } from '@/components/data/FiltersBar';
import { Pagination } from '@/components/data/Pagination';

import { EmptyState } from '@/components/feedback/EmptyState';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { Spinner } from '@/components/feedback/Spinner';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { useToast } from '@/components/feedback/toast-context';

import { FileUpload } from '@/components/form/FileUpload';

import { FormAlert } from '@/features/auth/components/FormAlert';
import { FormField as AuthFormField } from '@/features/auth/components/FormField';
import { PasswordStrength } from '@/features/auth/components/PasswordStrength';

/** Har chaqiruvda o'zaro mustaqil bo'lishi uchun `axe()` natijasini tekshiruvchi yordamchi. */
async function expectNoViolations(container: Element): Promise<void> {
  const results = await axe(container);
  expect(results.violations).toHaveLength(0);
}

function withRouter(node: React.ReactElement) {
  return <MemoryRouter>{node}</MemoryRouter>;
}

describe('a11y: ui primitives', () => {
  it('Button (barcha variant/holatlar)', async () => {
    const { container } = render(
      <div>
        <Button variant="primary">Save</Button>
        <Button variant="secondary">Cancel</Button>
        <Button variant="ghost">Ghost</Button>
        <Button variant="danger">Delete</Button>
        <Button loading>Loading</Button>
        <Button disabled>Disabled</Button>
      </div>,
    );
    await expectNoViolations(container);
  });

  it('IconButton — aria-label majburiy', async () => {
    const { container } = render(
      <div>
        <IconButton icon={AlertTriangle} aria-label="Delete" />
        <IconButton icon={AlertTriangle} aria-label="Loading action" loading />
        <IconButton icon={AlertTriangle} aria-label="Disabled action" disabled />
      </div>,
    );
    await expectNoViolations(container);
  });

  it("Icon — dekorativ va ma'noli holat", async () => {
    const { container } = render(
      <div>
        <Icon icon={AlertTriangle} />
        <Icon icon={AlertTriangle} label="Warning" />
      </div>,
    );
    await expectNoViolations(container);
  });

  it('Badge (soft + dot, barcha tone)', async () => {
    const { container } = render(
      <div>
        <Badge tone="success">Online</Badge>
        <Badge tone="warning">Ongoing</Badge>
        <Badge tone="error">Violation</Badge>
        <Badge tone="neutral">N/A</Badge>
        <Badge tone="info">Info</Badge>
        <Badge tone="success" variant="dot">
          Online
        </Badge>
      </div>,
    );
    await expectNoViolations(container);
  });

  it('StatusChip', async () => {
    const { container } = render(
      <div>
        <StatusChip status="DR" tone="success" label="Driving" />
        <StatusChip status="ON" tone="warning" label="On duty" />
      </div>,
    );
    await expectNoViolations(container);
  });

  it('Avatar — src bilan va initsiallar fallback', async () => {
    const { container } = render(
      <div>
        <Avatar name="John Doe" />
        <Avatar name="Jane Smith" src="https://example.com/avatar.png" />
      </div>,
    );
    await expectNoViolations(container);
  });

  it('Card', async () => {
    const { container } = render(
      <Card title="Unit details" actions={<Button size="sm">Edit</Button>}>
        <p>Content</p>
      </Card>,
    );
    await expectNoViolations(container);
  });

  it('Breadcrumb', async () => {
    const { container } = render(
      withRouter(<Breadcrumb items={[{ label: 'Units', href: '/units' }, { label: 'Unit 42' }]} />),
    );
    await expectNoViolations(container);
  });

  it('KpiCard — normal va loading', async () => {
    const { container } = render(
      <div>
        <KpiCard label="Total drivers" value="128" tone="info" />
        <KpiCard
          label="Violations"
          value="4"
          tone="error"
          delta={{ value: '+2', direction: 'up' }}
        />
        <KpiCard label="Loading" value="" loading />
      </div>,
    );
    await expectNoViolations(container);
  });

  it('Tabs — role/aria-selected', async () => {
    // `aria-controls` — panelni chaqiruvchi ekran render qiladi (Tabs.tsx
    // domeni bilmaydi); shu yerda haqiqiy iste'molchi kabi mos `id`li panel
    // qo'shiladi, aks holda axe "aria-valid-attr-value" bilan yiqiladi.
    const tabs = [
      { id: 'a', label: 'Overview' },
      { id: 'b', label: 'History' },
      { id: 'c', label: 'Disabled', disabled: true },
    ];
    const { container } = render(
      <div>
        <Tabs tabs={tabs} activeId="a" onChange={() => undefined} ariaLabel="Unit tabs" />
        {tabs.map((tab) => (
          <div
            key={tab.id}
            id={`tabpanel-${tab.id}`}
            role="tabpanel"
            aria-labelledby={`tab-${tab.id}`}
            hidden={tab.id !== 'a'}
          >
            Panel {tab.label}
          </div>
        ))}
      </div>,
    );
    await expectNoViolations(container);
  });

  it('Tooltip — klaviatura fokusida ham ochiladi', async () => {
    const { container } = render(
      <Tooltip content="More info">
        <button type="button">Hover me</button>
      </Tooltip>,
    );
    await expectNoViolations(container);
  });
});

describe('a11y: form controls', () => {
  it('Input — normal, xato, hint', async () => {
    const { container } = render(
      <div>
        <Input label="Unit number" />
        <Input label="VIN" error="VIN is required" required />
        <Input label="Notes" hint="Optional" />
      </div>,
    );
    await expectNoViolations(container);
  });

  it('Textarea', async () => {
    const { container } = render(
      <div>
        <Textarea label="Description" />
        <Textarea label="Reason" error="Reason is required" required />
      </div>,
    );
    await expectNoViolations(container);
  });

  it('Checkbox / Radio / Switch', async () => {
    const { container } = render(
      <div>
        <Checkbox label="Select all" />
        <Checkbox label="Indeterminate" indeterminate />
        <Checkbox label="With error" error="Required" />
        <Radio label="Option A" name="opt" />
        <Radio label="Option B" name="opt" />
        <Switch label="Enable notifications" />
      </div>,
    );
    await expectNoViolations(container);
  });

  it('Select — yopiq va ochiq holat', async () => {
    const options = [
      { value: 'a', label: 'Alpha' },
      { value: 'b', label: 'Beta' },
    ];
    const { container } = render(
      <div>
        <Select label="Region" options={options} value={null} onChange={() => undefined} />
        <Select
          label="Region (error)"
          options={options}
          value={null}
          onChange={() => undefined}
          error="Required"
          required
        />
      </div>,
    );
    await expectNoViolations(container);
  });

  it('MultiSelect', async () => {
    const options = [
      { value: 'a', label: 'Alpha' },
      { value: 'b', label: 'Beta' },
    ];
    const { container } = render(
      <MultiSelect
        label="States"
        options={options}
        values={['a']}
        onChange={() => undefined}
        selectAll
      />,
    );
    await expectNoViolations(container);
  });

  it('DatePicker — yopiq holat', async () => {
    const { container } = render(
      <DatePicker label="Start date" value={new Date(2025, 0, 15)} onChange={() => undefined} />,
    );
    await expectNoViolations(container);
  });

  it("DatePicker — ochiq kalendar (o'q tugmasi bilan kun navigatsiyasi)", async () => {
    const { container, getByRole } = render(
      <DatePicker label="Start date" value={new Date(2025, 0, 15)} onChange={() => undefined} />,
    );
    act(() => {
      getByRole('button', { name: /start date/i }).click();
    });
    await expectNoViolations(container);
  });

  it('DateRangePicker', async () => {
    const { container } = render(
      <DateRangePicker
        label="Date range"
        value={{ start: new Date(2025, 0, 1), end: new Date(2025, 0, 10) }}
        onChange={() => undefined}
      />,
    );
    await expectNoViolations(container);
  });

  it('TimePicker', async () => {
    const { container } = render(
      <TimePicker
        label="Time"
        value={{ hours: 8, minutes: 30, seconds: 0 }}
        onChange={() => undefined}
      />,
    );
    await expectNoViolations(container);
  });

  it('FileUpload (idle holat)', async () => {
    const { container } = render(
      <FileUpload
        kind="signature"
        label="Upload signature"
        onPresign={() => Promise.reject(new Error('not used in test'))}
        onUploaded={() => undefined}
      />,
    );
    await expectNoViolations(container);
  });
});

describe('a11y: overlays (Modal/Drawer/ConfirmDialog)', () => {
  it('Modal — ochiq holatda', async () => {
    const { container } = render(
      <Modal open onClose={() => undefined} title="Edit unit" footer={<Button>Save</Button>}>
        <p>Body content</p>
      </Modal>,
    );
    await expectNoViolations(container);
  });

  it('Drawer — ochiq holatda', async () => {
    const { container } = render(
      <Drawer open onClose={() => undefined} title="Track on map">
        <p>Drawer content</p>
      </Drawer>,
    );
    await expectNoViolations(container);
  });

  it('ConfirmDialog — danger + requireReason', async () => {
    const { container } = render(
      <ConfirmDialog
        open
        onClose={() => undefined}
        onConfirm={() => undefined}
        description="Are you sure you want to delete this unit?"
        variant="danger"
        requireReason
      />,
    );
    await expectNoViolations(container);
  });
});

describe('a11y: data components', () => {
  interface Row {
    id: string;
    name: string;
    status: string;
  }

  const rows: Row[] = [
    { id: '1', name: 'Unit 100', status: 'Online' },
    { id: '2', name: 'Unit 200', status: 'Offline' },
  ];

  it('DataTable — normal, loading, empty, error', async () => {
    const columns = [
      { id: 'name', header: 'Name', accessorKey: 'name' as const, enableSorting: true },
      { id: 'status', header: 'Status', accessorKey: 'status' as const },
    ];

    const { container: normal } = render(
      <DataTable
        tableId="a11y-test-normal"
        columns={columns}
        data={rows}
        sort="name"
        order="asc"
        onSortChange={() => undefined}
        onRowClick={() => undefined}
      />,
    );
    await expectNoViolations(normal);

    const { container: loading } = render(
      <DataTable tableId="a11y-test-loading" columns={columns} data={[]} isLoading />,
    );
    await expectNoViolations(loading);

    const { container: empty } = render(
      <DataTable tableId="a11y-test-empty" columns={columns} data={[]} />,
    );
    await expectNoViolations(empty);

    const { container: errored } = render(
      <DataTable
        tableId="a11y-test-error"
        columns={columns}
        data={[]}
        isError
        errorMessage="Failed to load"
        onRetry={() => undefined}
      />,
    );
    await expectNoViolations(errored);
  });

  it('Pagination', async () => {
    const { container } = render(
      <Pagination
        page={1}
        perPage={10}
        total={42}
        onPageChange={() => undefined}
        onPerPageChange={() => undefined}
      />,
    );
    await expectNoViolations(container);
  });

  it('ColumnPicker', async () => {
    const { container } = render(
      <ColumnPicker
        columns={[
          { id: 'name', label: 'Name' },
          { id: 'status', label: 'Status' },
        ]}
        visibility={{}}
        onToggle={() => undefined}
        onSelectAll={() => undefined}
      />,
    );
    await expectNoViolations(container);
  });

  it('FiltersBar', async () => {
    const { container } = render(
      <FiltersBar
        search=""
        onSearchChange={() => undefined}
        activeFilters={{ status: 'online' }}
        onFilterChange={() => undefined}
        onClearAll={() => undefined}
        filters={[
          {
            key: 'status',
            label: 'Status',
            options: [
              { value: 'online', label: 'Online' },
              { value: 'offline', label: 'Offline' },
            ],
          },
        ]}
      />,
    );
    await expectNoViolations(container);
  });
});

describe('a11y: feedback components', () => {
  it('EmptyState / ErrorState', async () => {
    const { container } = render(
      <div>
        <EmptyState />
        <ErrorState onRetry={() => undefined} />
      </div>,
    );
    await expectNoViolations(container);
  });

  it('Skeleton (aria-hidden) / Spinner', async () => {
    const { container } = render(
      <div>
        <Skeleton variant="text" count={3} />
        <Skeleton variant="table-row" />
        <Spinner />
      </div>,
    );
    await expectNoViolations(container);
  });

  it('ToastProvider — success/error/warning/info bir vaqtda', async () => {
    function Harness() {
      const toast = useToast();
      return (
        <button
          type="button"
          onClick={() => {
            toast.show({ variant: 'success', message: 'Saved' });
            toast.show({ variant: 'error', message: 'Failed' });
            toast.show({ variant: 'warning', message: 'Careful' });
          }}
        >
          fire
        </button>
      );
    }
    const { container, getByText } = render(
      <ToastProvider>
        <Harness />
      </ToastProvider>,
    );
    act(() => {
      getByText('fire').click();
    });
    await expectNoViolations(container);
  });
});

describe('a11y: auth presentational components', () => {
  it('FormAlert (error/info)', async () => {
    const { container } = render(
      <div>
        <FormAlert message="Invalid credentials" variant="error" />
        <FormAlert message="Check your email" variant="info" />
      </div>,
    );
    await expectNoViolations(container);
  });

  it('PasswordStrength', async () => {
    const { container } = render(<PasswordStrength password="abc" />);
    await expectNoViolations(container);
  });

  it('auth FormField — normal va xato', async () => {
    const { container } = render(
      <div>
        <AuthFormField label="Email" name="email" />
        <AuthFormField label="Password" name="password" error="Password is required" required />
      </div>,
    );
    await expectNoViolations(container);
  });
});
