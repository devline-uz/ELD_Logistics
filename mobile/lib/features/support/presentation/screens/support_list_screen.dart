/// **M-50 Contact Support (tiketlar ro'yxati)** (`/support`) —
/// Figma `1179:7142` (light) / `2665:36915` (dark), MAP.md §1.
///
/// Bo'sh holatda `EmptyState` + `Add Ticket` (`M-49`). Ro'yxat **faqat
/// onlayn** — tiketlar lokal keshda saqlanmaydi (M115 doirasidan tashqari).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/api_error.dart';
import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../../profile/profile_routes.dart';
import '../../domain/support_ticket.dart';
import '../controllers/support_controllers.dart';

class SupportListScreen extends ConsumerWidget {
  const SupportListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AdaptiveScaffold(
    // #B-64: planshetda tana cheklovsiz cho'zilmaydi.
    maxContentWidth: ContentWidth.wide,
    // Figma `1179:7142` app bar: faqat orqaga tugmasi + sarlavha.
    appBar: AppBarPrimary(
      title: context.l10n.supportTitle,
      leading: const AppBackButton(),
      showDefaultActions: false,
    ),
    backgroundColor: context.colors.bg,
    phone: (BuildContext context) => const SupportListBody(),
    tablet: (BuildContext context) => const SupportListBody(asTable: true),
  );
}

class SupportListBody extends ConsumerWidget {
  const SupportListBody({this.asTable = false, super.key});

  /// `T-27` (tz-mobile 1561): planshetda tiketlar jadval ko'rinishida
  /// (`Status · Ticket · Subject · Created`).
  final bool asTable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<List<SupportTicket>> tickets = ref.watch(supportListControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: asyncView<List<SupportTicket>>(
            tickets,
            loading: const Padding(
              padding: EdgeInsets.symmetric(vertical: Spacing.s20),
              child: LoadingSkeleton(),
            ),
            error: (Object error) => ErrorState(
              message: error is ApiError ? localizedApiError(l10n, error) : l10n.supportOfflineList,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.read(supportListControllerProvider.notifier).refresh().ignore(),
            ),
            data: (List<SupportTicket> items) => items.isEmpty
                ? EmptyState(
                    title: l10n.supportEmptyTitle,
                    message: l10n.supportEmptyMessage,
                    icon: Icons.confirmation_number_outlined,
                  )
                : RefreshIndicator(
                    onRefresh: () => ref.read(supportListControllerProvider.notifier).refresh(),
                    child: asTable
                        ? _TicketTable(items: items)
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: Spacing.s20),
                            itemCount: items.length,
                            separatorBuilder: (BuildContext context, int _) =>
                                Divider(height: Strokes.thin, color: context.colors.stroke),
                            itemBuilder: (BuildContext context, int index) =>
                                _TicketCard(ticket: items[index]),
                          ),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: Spacing.s20),
          child: AppButton.primary(
            label: l10n.supportAddTicket,
            icon: Icons.add,
            onPressed: () => context.push(ProfileRoute.supportNew),
          ),
        ),
      ],
    );
  }
}

/// Figma `1179:7142` dagi tiket bandi: holat badge'i + sana (yuqori qator),
/// `#122546` (Bold 16), `Subject` (Regular 14), tavsif (2 qator) va kursiv
/// `Contact On: …`. Bandlar 1 px `stroke` chizig'i bilan ajratiladi — Figma da
/// karta foni yo'q.
class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;

    return InkWell(
      onTap: () => context.push(ProfileRoute.supportTicket(ticket.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.s15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                StatusBadge(
                  label: localizedTicketStatus(l10n, ticket.status),
                  tone: ticketStatusTone(ticket.status),
                  dense: true,
                ),
                const SizedBox(width: Spacing.s10),
                Expanded(
                  child: Text(
                    AppFormats.fullDateTime(ticket.createdAt),
                    textAlign: TextAlign.right,
                    style: context.text.body15.copyWith(color: c.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.s5),
            Text(
              l10n.supportTicketNumber(ticket.displayNumber),
              style: context.text.body11.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: Spacing.s5),
            Text(
              ticket.subject,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.body15.copyWith(color: c.textPrimary),
            ),
            if (ticket.description.isNotEmpty) ...<Widget>[
              const SizedBox(height: Spacing.s5),
              Text(
                ticket.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.text.body15.copyWith(color: c.textPrimary),
              ),
            ],
            if (ticket.contactOn != null) ...<Widget>[
              const SizedBox(height: Spacing.s5),
              Text(
                l10n.supportContactOnValue(localizedChannel(l10n, ticket.contactOn!)),
                style: context.text.body15.copyWith(
                  color: c.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// **M115** — holat matni; haydovchi holatni o'zgartira olmaydi.
String localizedTicketStatus(AppLocalizations l10n, TicketStatus status) => switch (status) {
  TicketStatus.newly => l10n.supportStatusNew,
  TicketStatus.inProgress => l10n.supportStatusInProgress,
  TicketStatus.resolved => l10n.supportStatusResolved,
  TicketStatus.closed => l10n.supportStatusClosed,
};

/// Figma `1179:7142`: `New` — sariq (`warning`), `In Progress` — pushti/qizil
/// (`error`), `Resolved` — yashil (`success`). Ranglar ikkala temada bir xil (M81).
StatusTone ticketStatusTone(TicketStatus status) => switch (status) {
  TicketStatus.newly => StatusTone.warning,
  TicketStatus.inProgress => StatusTone.error,
  TicketStatus.resolved => StatusTone.success,
  TicketStatus.closed => StatusTone.neutral,
};

/// `Contact On` qiymatining matni (`M-50` va `M-51` ulashadi).
String localizedChannel(AppLocalizations l10n, ContactChannel channel) => switch (channel) {
  ContactChannel.email || ContactChannel.inApp => l10n.supportChannelEmail,
  ContactChannel.phone || ContactChannel.sms => l10n.supportChannelPhone,
};

/// `T-27 Contact Support` — planshet jadvali (tz-mobile 1561).
///
/// **A3:** ma'lumot manbai telefon ro'yxati bilan bir xil
/// (`supportListControllerProvider`) — bu yerda faqat tartib boshqacha.
class _TicketTable extends StatelessWidget {
  const _TicketTable({required this.items});

  final List<SupportTicket> items;

  /// Ustun nisbatlari: `Status · Ticket · Subject · Created`.
  static const List<int> _flex = <int>[2, 2, 5, 3];

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          color: c.surfaceAlt,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.s15, vertical: Spacing.s10),
          child: Row(
            children: <Widget>[
              for (final (int i, String label) in <String>[
                l10n.supportColStatus,
                l10n.supportColTicket,
                l10n.supportSubject,
                l10n.supportColCreated,
              ].indexed)
                Expanded(
                  flex: _flex[i],
                  child: Text(label, style: context.text.body14.copyWith(color: c.textSecondary)),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (BuildContext context, int _) =>
                Divider(height: Strokes.thin, color: context.colors.stroke),
            itemBuilder: (BuildContext context, int index) => _TicketRow(ticket: items[index]),
          ),
        ),
      ],
    );
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;
    final TextStyle cell = context.text.body13.copyWith(color: c.textPrimary);

    return InkWell(
      onTap: () => context.push(ProfileRoute.supportTicket(ticket.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.s15, vertical: Spacing.s15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: _TicketTable._flex[0],
              child: Align(
                alignment: Alignment.centerLeft,
                child: StatusBadge(
                  label: localizedTicketStatus(l10n, ticket.status),
                  tone: ticketStatusTone(ticket.status),
                  dense: true,
                ),
              ),
            ),
            Expanded(
              flex: _TicketTable._flex[1],
              child: Text(
                l10n.supportTicketNumber(ticket.displayNumber),
                style: context.text.body11.copyWith(color: c.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: _TicketTable._flex[2],
              child: Text(
                AppFormats.orNa(ticket.subject),
                style: cell,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: _TicketTable._flex[3],
              child: Text(
                AppFormats.fullDateTime(ticket.createdAt),
                style: context.text.body14.copyWith(color: c.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
