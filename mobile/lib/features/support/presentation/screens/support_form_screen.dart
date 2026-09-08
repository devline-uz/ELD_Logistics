/// **M-49 Add Ticket** (`/support/new`) — Figma `1179:7028` (light) /
/// `2665:28217` (dark).
///
/// TZ §11.8: `Contact On` (email/telefon), `Subject` (majburiy),
/// `Description`, `Confirm`. Validatsiya domenda (`TicketDraft.validate`).
/// Oflayn — outbox (`SubmitOutcome.queued`), M114: biriktirmalar ≤3.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../../profile/domain/submit_outcome.dart';
import '../../domain/support_ticket.dart';
import '../../domain/ticket_draft.dart';
import '../controllers/support_controllers.dart';

class SupportFormScreen extends ConsumerWidget {
  const SupportFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AdaptiveScaffold(
    // #B-64: planshetda tana cheklovsiz cho'zilmaydi.
    maxContentWidth: ContentWidth.single,
    appBar: AppBarPrimary(title: context.l10n.supportTitle, leading: const AppBackButton()),
    backgroundColor: context.colors.bg,
    phone: (BuildContext c) => SupportFormPane(onDone: () => _cancel(c)),
    tablet: (BuildContext c) => SupportFormPane(onDone: () => _cancel(c)),
  );
}

/// `M-49` ekrani va `T-28 Add Ticket` planshet modali uchun yagona tana (A3).
///
/// Matn kontrollerlari va yuborish natijasini kuzatish shu yerda; validatsiya
/// esa domenda (`TicketDraft.validate`). Yopilish usuli chaqiruvchida
/// ([onDone]): ekranda `go_router` pop, modalda `Navigator.pop`.
class SupportFormPane extends ConsumerStatefulWidget {
  const SupportFormPane({required this.onDone, super.key});

  final VoidCallback onDone;

  @override
  ConsumerState<SupportFormPane> createState() => _SupportFormPaneState();
}

class _SupportFormPaneState extends ConsumerState<SupportFormPane> {
  final TextEditingController _subject = TextEditingController();
  final TextEditingController _description = TextEditingController();

  @override
  void dispose() {
    _subject.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    ref.listen<TicketFormState>(ticketFormControllerProvider, (
      TicketFormState? previous,
      TicketFormState next,
    ) {
      if (next.outcome != null && previous?.outcome != next.outcome) {
        final String message = next.outcome == SubmitOutcome.queued
            ? l10n.supportQueued
            : l10n.supportTicketCreated;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        widget.onDone();
      }
    });

    return SupportFormBody(subject: _subject, description: _description);
  }
}

void _cancel(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  }
}

class SupportFormBody extends ConsumerWidget {
  const SupportFormBody({required this.subject, required this.description, super.key});

  final TextEditingController subject;
  final TextEditingController description;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final TicketFormState state = ref.watch(ticketFormControllerProvider);
    final TicketFormController controller = ref.read(ticketFormControllerProvider.notifier);
    final bool subjectMissing =
        state.showErrors && state.errors.contains(TicketValidationError.subjectRequired);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: Spacing.s20),
            children: <Widget>[
              SettingsCard(
                children: <Widget>[
                  // Figma da `Contact On` sarlavhasi ko'rinmaydi — radio
                  // tugmalar to'g'ridan-to'g'ri sarlavha ostida turadi.
                  Wrap(
                    spacing: Spacing.s20,
                    runSpacing: Spacing.s5,
                    children: <Widget>[
                      for (final ContactChannel channel in ContactChannel.selectable)
                        _ChannelRadio(
                          label: _channelLabel(l10n, channel),
                          selected: state.draft.contactOn == channel,
                          onTap: state.submitting ? null : () => controller.setChannel(channel),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: Spacing.cardGap),
              SettingsCard(
                children: <Widget>[
                  Text(
                    l10n.supportSubject,
                    style: context.text.body14.copyWith(color: context.colors.textPrimary),
                  ),
                  AppTextField(
                    controller: subject,
                    hint: l10n.supportSubjectHint,
                    enabled: !state.submitting,
                    errorText: subjectMissing ? l10n.supportSubjectRequired : null,
                    onChanged: controller.setSubject,
                  ),
                ],
              ),
              const SizedBox(height: Spacing.cardGap),
              SettingsCard(
                children: <Widget>[
                  Text(
                    l10n.supportDescription,
                    style: context.text.body14.copyWith(color: context.colors.textPrimary),
                  ),
                  AppTextField(
                    controller: description,
                    hint: l10n.supportDescriptionHint,
                    minLines: 4,
                    maxLines: 6,
                    enabled: !state.submitting,
                    onChanged: controller.setDescription,
                  ),
                ],
              ),
              if (state.error != null) ...<Widget>[
                const SizedBox(height: Spacing.cardGap),
                Text(
                  localizedApiError(l10n, state.error!),
                  style: context.text.body16.copyWith(color: context.colors.error),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: Spacing.s20),
          child: Row(
            children: <Widget>[
              Expanded(
                child: AppButton.secondary(
                  label: l10n.commonCancel,
                  onPressed: state.submitting ? null : () => _cancel(context),
                ),
              ),
              const SizedBox(width: Spacing.s10),
              Expanded(
                child: AppButton.primary(
                  label: l10n.supportConfirm,
                  busy: state.submitting,
                  onPressed: state.submitting ? null : controller.submit,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Figma `1179:7028` dagi radio tugma. Teginish maydoni M8 bo'yicha ≥48 dp.
class _ChannelRadio extends StatelessWidget {
  const _ChannelRadio({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// Figma: halqa 24×24, ichki nuqta 12×12.
  static const double _ringSize = 24;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      label: label,
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.pillRadius,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: touchTarget(context)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: _ringSize,
                height: _ringSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: onTap == null ? c.textDisabled : c.textPrimary,
                    width: Strokes.emphasis,
                  ),
                ),
                child: selected
                    ? DecoratedBox(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: c.textPrimary),
                        child: const SizedBox(width: _ringSize / 2, height: _ringSize / 2),
                      )
                    : null,
              ),
              const SizedBox(width: Spacing.s10),
              Text(label, style: context.text.body15.copyWith(color: c.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}

String _channelLabel(AppLocalizations l10n, ContactChannel channel) => switch (channel) {
  ContactChannel.email => l10n.supportChannelEmail,
  ContactChannel.phone => l10n.supportChannelPhone,
  // `sms` / `in_app` formada tanlanmaydi (Figma `1179:7028`), lekin backend
  // qaytarishi mumkin — matn eng yaqin kanaldan olinadi.
  ContactChannel.sms => l10n.supportChannelPhone,
  ContactChannel.inApp => l10n.supportChannelEmail,
};
