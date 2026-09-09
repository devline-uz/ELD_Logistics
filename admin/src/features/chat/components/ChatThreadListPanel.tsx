/**
 * Chap panel — suhbatlar ro'yxati: qidiruv, oxirgi xabar parchasi, vaqt,
 * o'qilmagan badge (F130). `GET /chat/threads` `search` parametrini
 * qo'llab-quvvatlamaydi (§17 D36) — qidiruv mijoz tomonida, joriy sahifa
 * ustida filtrlaydi.
 */
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';

import type { ChatThread, PerPage } from '@/api/types';
import { EmptyState } from '@/components/feedback/EmptyState';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { FiltersBar } from '@/components/data/FiltersBar';
import { Pagination } from '@/components/data/Pagination';
import { Avatar } from '@/components/ui/Avatar';
import { Badge } from '@/components/ui/Badge';
import { useDateFormat } from '@/hooks/useDateFormat';

export interface ChatThreadListPanelProps {
  threads: ChatThread[];
  total: number;
  isLoading: boolean;
  isError: boolean;
  onRetry: () => void;
  search: string;
  onSearchChange: (value: string) => void;
  selectedDriverId?: string;
  onSelect: (driverId: string) => void;
  page: number;
  perPage: PerPage;
  onPageChange: (page: number) => void;
  onPerPageChange: (perPage: PerPage) => void;
}

function lastMessagePreview(thread: ChatThread, t: (key: string) => string): string | undefined {
  const message = thread.last_message;
  if (!message) return undefined;
  if (message.kind === 'text') return message.text;
  if (message.kind === 'image') return t('chat.threads.preview.image');
  if (message.kind === 'file') return t('chat.threads.preview.file');
  if (message.kind === 'location') return t('chat.threads.preview.location');
  return message.text;
}

export function ChatThreadListPanel({
  threads,
  total,
  isLoading,
  isError,
  onRetry,
  search,
  onSearchChange,
  selectedDriverId,
  onSelect,
  page,
  perPage,
  onPageChange,
  onPerPageChange,
}: ChatThreadListPanelProps) {
  const { t } = useTranslation();
  const dateFormat = useDateFormat();

  const filtered = useMemo(() => {
    const term = search.trim().toLowerCase();
    if (!term) return threads;
    return threads.filter((thread) => (thread.driver_name ?? '').toLowerCase().includes(term));
  }, [threads, search]);

  return (
    <div className="flex w-80 shrink-0 flex-col border-r border-stroke">
      <div className="border-b border-stroke p-4">
        <h2 className="mb-3 text-body-lg font-semibold text-neutral-900">
          {t('chat.threads.title')}
        </h2>
        <FiltersBar
          search={search}
          onSearchChange={onSearchChange}
          searchPlaceholder={t('chat.threads.searchPlaceholder')}
          activeFilters={{}}
          onFilterChange={() => undefined}
          onClearAll={() => onSearchChange('')}
        />
      </div>

      <div className="flex-1 overflow-y-auto">
        {isLoading ? (
          <div className="p-4">
            <Skeleton variant="card" count={5} />
          </div>
        ) : isError ? (
          <ErrorState message={t('chat.threads.loadFailed')} onRetry={onRetry} />
        ) : threads.length === 0 ? (
          <EmptyState title={t('chat.threads.empty.title')} />
        ) : filtered.length === 0 ? (
          <EmptyState
            title={t('ui.overlay.emptyState.noResultsTitle')}
            description={t('ui.overlay.emptyState.noResultsDescription')}
            action={
              <button
                type="button"
                onClick={() => onSearchChange('')}
                className="text-body-sm font-medium text-primary hover:underline"
              >
                {t('ui.overlay.emptyState.clearFilters')}
              </button>
            }
          />
        ) : (
          <ul>
            {filtered.map((thread) => {
              const preview = lastMessagePreview(thread, t);
              const isSelected = thread.driver_id === selectedDriverId;
              return (
                <li key={thread.driver_id}>
                  <button
                    type="button"
                    aria-current={isSelected ? 'true' : undefined}
                    onClick={() => thread.driver_id && onSelect(thread.driver_id)}
                    className={`flex w-full items-start gap-3 border-b border-stroke px-4 py-3 text-left hover:bg-surface-muted ${
                      isSelected ? 'bg-light' : ''
                    }`}
                  >
                    <Avatar name={thread.driver_name ?? t('common.na')} size="md" />
                    <div className="min-w-0 flex-1">
                      <div className="flex items-center justify-between gap-2">
                        <span className="truncate text-body font-medium text-neutral-900">
                          {thread.driver_name ?? t('common.na')}
                        </span>
                        {thread.last_message?.sent_at ? (
                          <span className="shrink-0 text-body-xs text-neutral-400">
                            {dateFormat.formatRelative(thread.last_message.sent_at)}
                          </span>
                        ) : null}
                      </div>
                      <div className="flex items-center justify-between gap-2">
                        <span className="truncate text-body-sm text-neutral-600">
                          {preview ?? t('chat.threads.noMessages')}
                        </span>
                        {thread.unread_count ? (
                          <Badge tone="error" className="shrink-0">
                            {thread.unread_count}
                          </Badge>
                        ) : null}
                      </div>
                    </div>
                  </button>
                </li>
              );
            })}
          </ul>
        )}
      </div>

      {!isLoading && !isError && total > perPage ? (
        <div className="border-t border-stroke p-3">
          <Pagination
            page={page}
            perPage={perPage}
            total={total}
            onPageChange={onPageChange}
            onPerPageChange={onPerPageChange}
          />
        </div>
      ) : null}
    </div>
  );
}

export default ChatThreadListPanel;
