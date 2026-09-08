/// **M-51 Ticket - View** (`/support/:id`) — Figma `1158:462`.
///
/// TZ §11.1 bu ekranni 🎨 (Figma da yo'q) deb belgilagan — aslida **bor**
/// (`tasks.md` «Registrda topilgan xatolar»). Tiket sarlavhasi + holat badge'i
/// (**M115**, haydovchi holatni o'zgartira olmaydi) va xabarlar tasmasi;
/// pastda javob yozish maydoni (oflayn — outbox).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error.dart';
import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../../profile/domain/submit_outcome.dart';
import '../../domain/support_ticket.dart';
import '../controllers/support_controllers.dart';
import 'support_list_screen.dart';

class TicketThreadScreen extends ConsumerStatefulWidget {
  const TicketThreadScreen({required this.ticketId, super.key});

  final String ticketId;

  @override
  ConsumerState<TicketThreadScreen> createState() => _TicketThreadScreenState();
}

class _TicketThreadScreenState extends ConsumerState<TicketThreadScreen> {
  final TextEditingController _reply = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final String text = _reply.text.trim();
    if (text.isEmpty || _sending) {
      return;
    }
    setState(() => _sending = true);
    final AppLocalizations l10n = context.l10n;
    try {
      final SubmitOutcome outcome = await ref
          .read(ticketThreadControllerProvider(widget.ticketId).notifier)
          .reply(text);
      if (!mounted) {
        return;
      }
      _reply.clear();
      if (outcome == SubmitOutcome.queued) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.supportQueued)));
      }
    } on ApiError catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(localizedApiError(l10n, error))));
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<TicketThread> thread = ref.watch(
      ticketThreadControllerProvider(widget.ticketId),
    );

    final SupportTicket? ticket = thread.value?.ticket;
    return AdaptiveScaffold(
      // #B-64: planshetda tana cheklovsiz cho'zilmaydi.
      maxContentWidth: ContentWidth.single,
      appBar: AppBarPrimary(
        // Figma `1158:462`: sarlavha — tiket raqami; yuklanmagunicha umumiy nom.
        title: ticket == null ? l10n.supportTitle : l10n.supportTicketHeading(ticket.displayNumber),
        leading: const AppBackButton(),
      ),
      backgroundColor: context.colors.bg,
      phone: (BuildContext context) => _body(thread),
      tablet: (BuildContext context) => _body(thread),
    );
  }

  Widget _body(AsyncValue<TicketThread> thread) {
    final AppLocalizations l10n = context.l10n;

    return asyncView<TicketThread>(
      thread,
      loading: const Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.s20),
        child: LoadingSkeleton(),
      ),
      error: (Object error) => ErrorState(
        message: error is ApiError ? localizedApiError(l10n, error) : l10n.supportOfflineList,
        retryLabel: l10n.commonRetry,
        onRetry: () =>
            ref.read(ticketThreadControllerProvider(widget.ticketId).notifier).refresh().ignore(),
      ),
      data: (TicketThread data) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: Spacing.s20),
              children: <Widget>[
                _Header(ticket: data.ticket),
                const SizedBox(height: Spacing.cardGap),
                Text(
                  l10n.supportMessages,
                  style: context.text.body14.copyWith(color: context.colors.textPrimary),
                ),
                const SizedBox(height: Spacing.s10),
                if (data.messages.isEmpty)
                  EmptyState(
                    title: l10n.supportNoMessagesTitle,
                    message: l10n.supportNoMessagesMessage,
                    icon: Icons.forum_outlined,
                  )
                else
                  for (final SupportMessage message in data.messages) ...<Widget>[
                    _MessageBubble(message: message),
                    const SizedBox(height: Spacing.s10),
                  ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.s20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: AppTextField(
                    controller: _reply,
                    hint: l10n.supportReplyHint,
                    minLines: 1,
                    maxLines: 4,
                    enabled: !_sending,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (String _) => _send(),
                  ),
                ),
                const SizedBox(width: Spacing.s10),
                AppButton.primary(
                  label: l10n.supportSend,
                  expand: false,
                  busy: _sending,
                  onPressed: _sending ? null : _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;

    return SettingsCard(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                l10n.supportTicketHeading(ticket.displayNumber),
                style: context.text.body14.copyWith(color: c.textPrimary),
              ),
            ),
            StatusBadge(
              label: localizedTicketStatus(l10n, ticket.status),
              tone: ticketStatusTone(ticket.status),
              dense: true,
            ),
          ],
        ),
        Text(ticket.subject, style: context.text.body11.copyWith(color: c.textPrimary)),
        if (ticket.description.isNotEmpty) ...<Widget>[
          Text(l10n.supportDescription, style: context.text.body14.copyWith(color: c.textPrimary)),
          Text(
            ticket.description,
            textAlign: TextAlign.justify,
            style: context.text.body15.copyWith(color: c.textPrimary),
          ),
        ],
        if (ticket.contactOn != null)
          Text(
            l10n.supportContactOnValue(localizedChannel(l10n, ticket.contactOn!)),
            style: context.text.body17.copyWith(
              color: c.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        if (ticket.createdAt != null)
          Row(
            children: <Widget>[
              Icon(Icons.calendar_today_outlined, size: Spacing.s15, color: c.textSecondary),
              const SizedBox(width: Spacing.s5),
              Expanded(
                child: Text(
                  l10n.supportCreatedOn(AppFormats.fullDateTime(ticket.createdAt)),
                  style: context.text.body15.copyWith(color: c.textSecondary),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final SupportMessage message;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: Radii.cardRadius,
        border: Border.all(color: c.stroke, width: Strokes.thin),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.s15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (message.senderName != null)
              Text(
                message.senderName!,
                style: context.text.body16.copyWith(color: c.textSecondary),
              ),
            Text(message.text, style: context.text.body15.copyWith(color: c.textPrimary)),
            if (message.createdAt != null) ...<Widget>[
              const SizedBox(height: Spacing.s5),
              Text(
                AppFormats.fullDateTime(message.createdAt),
                style: context.text.body17.copyWith(color: c.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
