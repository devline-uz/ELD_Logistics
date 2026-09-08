/**
 * Chat — TanStack Query hooklari (Bosqich 7, fe-api §3/§7, TZ §15.4,
 * `docs/tz-admin-frontend.md` §7.9).
 *
 * Endpointlar `admin/openapi/swagger.json` bilan tasdiqlangan:
 * `GET /chat/threads`, `GET /chat/threads/{driver_id}/messages`,
 * `POST /chat/threads/{driver_id}/messages`, `POST /chat/messages/{id}/read`.
 * Ruxsat: `chat.read` (o'qish/belgilash), `chat.send` (yuborish).
 *
 * Fayl biriktirish — `src/api/queries/files.ts`dagi `presignFile({kind:'chat',…})`
 * bilan olingan `key` shu fayldagi `useChatMessageSend`ga `file_key` sifatida
 * beriladi; bu yerda alohida presign yordamchisi **yozilmagan** (bosqich
 * ko'rsatmasi).
 *
 * Haydash rejimi ogohlantirishi: haydovchi `DR` holatida bo'lsa backend
 * `409 DRIVING_MODE_BLOCKED` qaytaradi (driver distraction siyosati) — ofis
 * tomoni baribir yoza oladi. Bu hook darajasida maxsus qayta ishlanmaydi,
 * `ApiError.code` orqali ekran qatlami alohida ogohlantirish ko'rsatadi.
 */
import {
  useInfiniteQuery,
  useMutation,
  useQuery,
  useQueryClient,
  type InfiniteData,
  type QueryClient,
  type UseInfiniteQueryResult,
  type UseQueryResult,
} from '@tanstack/react-query';

import { api } from '@/api/client';
import type { ApiError } from '@/lib/errors';
import type {
  ChatMessage,
  ChatMessageCreate,
  ChatThread,
  ChatThreadsListParams,
  CursorMeta,
  IsoDateTime,
  ListResponse,
} from '@/api/types';

/** `GET /chat/threads/{driver_id}/messages` sahifasi — kursorli `meta`. */
export interface ChatMessagesPage {
  data?: ChatMessage[];
  meta?: CursorMeta;
}

/**
 * Sahifa hajmi — `useChatMessages` va `useChatMessageSend`/ack yordamchilari
 * **bir xil** qiymatdan foydalanishi shart, aks holda optimistik yangilanish
 * boshqa query key'ga tegib ketadi (kesh mos kelmaydi).
 */
export const CHAT_MESSAGES_PAGE_SIZE = 50;

/** Query key fabrikasi — `['chat', <tur>, ...]` (fe-conventions §3). */
export const chatKeys = {
  all: ['chat'] as const,
  threadLists: () => [...chatKeys.all, 'threads', 'list'] as const,
  threadList: (params: ChatThreadsListParams) => [...chatKeys.threadLists(), params] as const,
  messages: () => [...chatKeys.all, 'messages'] as const,
  messagesForThread: (driverId: string, limit: number = CHAT_MESSAGES_PAGE_SIZE) =>
    [...chatKeys.messages(), driverId, limit] as const,
};

/**
 * `GET /chat/threads` (`chat.read`) — bitta thread/haydovchi, hech qachon
 * yozishmagan haydovchilar ham kiradi (suhbat boshlash uchun).
 */
export function useChatThreadsList(
  params: ChatThreadsListParams = {},
  options: { enabled?: boolean; refetchInterval?: number | false } = {},
): UseQueryResult<ListResponse<ChatThread>, ApiError> {
  return useQuery({
    queryKey: chatKeys.threadList(params),
    queryFn: async () => {
      const { data } = await api.GET('/chat/threads', { params: { query: params } });
      return data ?? {};
    },
    enabled: options.enabled ?? true,
    refetchInterval: options.refetchInterval ?? false,
  });
}

/**
 * `GET /chat/threads/{driver_id}/messages` (`chat.read`) — kursorli yuklash
 * (`before`), eng yangi xabar birinchi sahifada. "Load older" — `fetchNextPage`
 * (TanStack semantikasida "next" — kursor bo'yicha eskiroq sahifa).
 */
export function useChatMessages(
  driverId: string | undefined,
  options: { limit?: number; enabled?: boolean } = {},
): UseInfiniteQueryResult<InfiniteData<ChatMessagesPage>, ApiError> {
  const limit = options.limit ?? CHAT_MESSAGES_PAGE_SIZE;
  return useInfiniteQuery({
    queryKey: chatKeys.messagesForThread(driverId ?? '', limit),
    queryFn: async ({ pageParam }) => {
      const { data } = await api.GET('/chat/threads/{driver_id}/messages', {
        params: {
          path: { driver_id: driverId as string },
          query: { before: pageParam, limit },
        },
      });
      return data ?? {};
    },
    initialPageParam: undefined as IsoDateTime | undefined,
    getNextPageParam: (lastPage) =>
      lastPage.meta?.has_more ? lastPage.meta?.next_before : undefined,
    enabled: Boolean(driverId) && (options.enabled ?? true),
  });
}

/** Barcha sahifalarni bitta, eng yangidan-eskiga tartiblangan ro'yxatga tekislaydi. */
export function flattenChatMessages(
  data: InfiniteData<ChatMessagesPage> | undefined,
): ChatMessage[] {
  return data?.pages.flatMap((page) => page.data ?? []) ?? [];
}

function prependMessage(
  old: InfiniteData<ChatMessagesPage> | undefined,
  message: ChatMessage,
): InfiniteData<ChatMessagesPage> | undefined {
  if (!old) return old;
  const [firstPage, ...rest] = old.pages;
  const nextFirstPage: ChatMessagesPage = {
    ...firstPage,
    data: [message, ...(firstPage?.data ?? [])],
  };
  return { ...old, pages: [nextFirstPage, ...rest] };
}

function replaceMessage(
  old: InfiniteData<ChatMessagesPage> | undefined,
  matchId: string,
  message: ChatMessage,
): InfiniteData<ChatMessagesPage> | undefined {
  if (!old) return old;
  return {
    ...old,
    pages: old.pages.map((page) => ({
      ...page,
      data: page.data?.map((item) => (item.id === matchId ? message : item)),
    })),
  };
}

function patchMessage(
  old: InfiniteData<ChatMessagesPage> | undefined,
  id: string,
  patch: Partial<ChatMessage>,
): InfiniteData<ChatMessagesPage> | undefined {
  if (!old) return old;
  return {
    ...old,
    pages: old.pages.map((page) => ({
      ...page,
      data: page.data?.map((item) => (item.id === id ? { ...item, ...patch } : item)),
    })),
  };
}

function removeMessage(
  old: InfiniteData<ChatMessagesPage> | undefined,
  id: string,
): InfiniteData<ChatMessagesPage> | undefined {
  if (!old) return old;
  return {
    ...old,
    pages: old.pages.map((page) => ({
      ...page,
      data: page.data?.filter((item) => item.id !== id),
    })),
  };
}

let optimisticSeq = 0;
/** `crypto.randomUUID` mavjud bo'lmagan muhitlar uchun ham ishlaydigan vaqtinchalik id. */
function nextOptimisticId(): string {
  optimisticSeq += 1;
  return `optimistic-${Date.now().toString(16)}-${optimisticSeq}`;
}

/**
 * `POST /chat/threads/{driver_id}/messages` (`chat.send`) — optimistik
 * yangilanish: xabar darhol ro'yxat boshiga qo'shiladi (`status: 'sent'`),
 * xato bo'lsa (masalan `409 DRIVING_MODE_BLOCKED`) orqaga qaytariladi.
 *
 * `limit` — `useChatMessages` bilan **bir xil** bo'lishi shart (kesh key mosligi).
 */
export function useChatMessageSend(driverId: string, options: { limit?: number } = {}) {
  const queryClient = useQueryClient();
  const limit = options.limit ?? CHAT_MESSAGES_PAGE_SIZE;
  const queryKey = chatKeys.messagesForThread(driverId, limit);

  return useMutation({
    mutationFn: async (body: ChatMessageCreate) => {
      const { data } = await api.POST('/chat/threads/{driver_id}/messages', {
        params: { path: { driver_id: driverId } },
        body,
      });
      return data?.data;
    },
    onMutate: async (body) => {
      await queryClient.cancelQueries({ queryKey });
      const previous = queryClient.getQueryData<InfiniteData<ChatMessagesPage>>(queryKey);
      const optimisticId = nextOptimisticId();
      const optimisticMessage: ChatMessage = {
        id: optimisticId,
        driver_id: driverId,
        sender_side: 'office',
        status: 'sent',
        kind: body.kind,
        text: body.text,
        file_key: body.file_key,
        lat: body.lat,
        lng: body.lng,
        sent_at: new Date().toISOString(),
      };
      queryClient.setQueryData<InfiniteData<ChatMessagesPage>>(queryKey, (old) =>
        prependMessage(old, optimisticMessage),
      );
      return { previous, optimisticId };
    },
    onError: (_error, _body, context) => {
      if (context?.previous) {
        queryClient.setQueryData(queryKey, context.previous);
      } else if (context?.optimisticId) {
        queryClient.setQueryData<InfiniteData<ChatMessagesPage>>(queryKey, (old) =>
          removeMessage(old, context.optimisticId),
        );
      }
    },
    onSuccess: (message, _body, context) => {
      if (message && context?.optimisticId) {
        queryClient.setQueryData<InfiniteData<ChatMessagesPage>>(queryKey, (old) =>
          replaceMessage(old, context.optimisticId, message),
        );
      }
      void queryClient.invalidateQueries({ queryKey: chatKeys.threadLists() });
    },
  });
}

/**
 * `POST /chat/messages/{id}/read` (`chat.read`) — faqat qarama-qarshi
 * tomon tasdiqlashi mumkin; o'z xabaringni tasdiqlash `updated: 0` bilan
 * `200` qaytaradi (no-op).
 */
export function useChatMessageAck(options: { limit?: number } = {}) {
  const queryClient = useQueryClient();
  const limit = options.limit ?? CHAT_MESSAGES_PAGE_SIZE;
  return useMutation({
    mutationFn: async ({ id }: { id: string; driverId: string }) => {
      const { data } = await api.POST('/chat/messages/{id}/read', {
        params: { path: { id } },
      });
      return data?.data;
    },
    onSuccess: (_result, { id, driverId }) => {
      queryClient.setQueryData<InfiniteData<ChatMessagesPage>>(
        chatKeys.messagesForThread(driverId, limit),
        (old) => patchMessage(old, id, { status: 'read', read_at: new Date().toISOString() }),
      );
      void queryClient.invalidateQueries({ queryKey: chatKeys.threadLists() });
    },
  });
}

/**
 * `chat_message` WS hodisasi kelganda keshni yangilaydi (F163): agar shu
 * haydovchi threadi ochiq bo'lsa (kesh mavjud) yangi xabar boshiga qo'shiladi,
 * thread ro'yxati (`last_message`/`unread_count`) esa invalidatsiya qilinadi.
 */
export function applyChatMessageEvent(
  queryClient: QueryClient,
  message: ChatMessage,
  options: { limit?: number } = {},
): void {
  const limit = options.limit ?? CHAT_MESSAGES_PAGE_SIZE;
  if (message.driver_id) {
    queryClient.setQueryData<InfiniteData<ChatMessagesPage>>(
      chatKeys.messagesForThread(message.driver_id, limit),
      (old) => (old ? prependMessage(old, message) : old),
    );
  }
  void queryClient.invalidateQueries({ queryKey: chatKeys.threadLists() });
}

/**
 * `chat_message_read` WS hodisasi kelganda xabar holatini yangilaydi (F163).
 */
export function applyChatMessageReadEvent(
  queryClient: QueryClient,
  event: { id: string; driver_id: string; read_at?: IsoDateTime },
  options: { limit?: number } = {},
): void {
  const limit = options.limit ?? CHAT_MESSAGES_PAGE_SIZE;
  queryClient.setQueryData<InfiniteData<ChatMessagesPage>>(
    chatKeys.messagesForThread(event.driver_id, limit),
    (old) => patchMessage(old, event.id, { status: 'read', read_at: event.read_at }),
  );
  void queryClient.invalidateQueries({ queryKey: chatKeys.threadLists() });
}
