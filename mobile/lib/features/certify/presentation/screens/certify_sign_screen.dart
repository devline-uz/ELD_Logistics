/// `M-30 Certify — Sign` — Figma `1102:817` / `1102:1599` (tz-mobile 1637–1665).
///
/// M126: bir nechta kun tanlangan bo'lsa ham **bitta** imzo olinadi.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/security/screen_protection.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/certify_models.dart';
import '../controllers/certify_list_controller.dart';
import '../controllers/certify_providers.dart';
import '../controllers/certify_sign_controller.dart';

class CertifySignScreen extends ConsumerStatefulWidget {
  const CertifySignScreen({required this.date, super.key});

  /// Marshrutdagi kun (`/certify/:date/sign`).
  final DateTime date;

  @override
  ConsumerState<CertifySignScreen> createState() => _CertifySignScreenState();
}

// **M157 / #B-139:** imzo ekrani `FLAG_SECURE` ro'yxatida (`M-30`) —
// mixin `initState` da yoqadi, `dispose` da majburiy o'chiradi.
class _CertifySignScreenState extends ConsumerState<CertifySignScreen>
    with SecureScreenMixin<CertifySignScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(certifySignControllerProvider.notifier).setDates(_datesFor(ref, widget.date));
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final CertifySignState state = ref.watch(certifySignControllerProvider);
    final AsyncValue<CertifyDay> day = ref.watch(certifyDayProvider(widget.date));

    return AdaptiveScaffold(
      maxContentWidth: ContentWidth.wide,
      backgroundColor: context.colors.bg,
      appBar: AppBarPrimary(
        title: l10n.certifySignTitle,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: l10n.commonCancel,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        // Figma `1102:817`: `Sign` ekranida o'ng tarafda amal ikonkalari yo'q.
        showDefaultActions: false,
      ),
      banners: <Widget>[
        if (day.value?.status == CertifyStatus.notReady)
          BannerStrip(message: l10n.certifyNotReadyHint, tone: BannerTone.warning),
      ],
      phone: (BuildContext c) => CertifySignBody(state: state, day: day, twoColumn: false),
      tablet: (BuildContext c) => CertifySignBody(state: state, day: day, twoColumn: true),
    );
  }
}

/// `T-12 Sign` planshet modali uchun tana (tz-mobile 1546).
///
/// **A3:** `M-30` ekrani bilan bir xil `certifySignControllerProvider` va
/// `CertifySignBody` — modal faqat `AppBarPrimary`/`BannerStrip` qobig'isiz
/// chizadi. Kunlarni tayyorlash (`setDates`) mantiqi ham shu yerda emas,
/// kontrollerda.
class CertifySignPane extends ConsumerStatefulWidget {
  const CertifySignPane({required this.date, this.twoColumn = true, super.key});

  final DateTime date;
  final bool twoColumn;

  @override
  ConsumerState<CertifySignPane> createState() => _CertifySignPaneState();
}

// Planshet modali ham aynan shu imzo tanasini ko'rsatadi (M157).
class _CertifySignPaneState extends ConsumerState<CertifySignPane>
    with SecureScreenMixin<CertifySignPane> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(certifySignControllerProvider.notifier).setDates(_datesFor(ref, widget.date));
    });
  }

  @override
  Widget build(BuildContext context) => CertifySignBody(
    state: ref.watch(certifySignControllerProvider),
    day: ref.watch(certifyDayProvider(widget.date)),
    twoColumn: widget.twoColumn,
  );
}

/// Tanlangan kunlar ro'yxati — ekran va modal uchun yagona manba (M126).
List<DateTime> _datesFor(WidgetRef ref, DateTime fallback) {
  final Set<DateTime> selected = ref.read(certifyListControllerProvider).selected;
  return selected.isEmpty ? <DateTime>[fallback] : (selected.toList()..sort());
}

class CertifySignBody extends ConsumerWidget {
  const CertifySignBody({
    required this.state,
    required this.day,
    required this.twoColumn,
    super.key,
  });

  final CertifySignState state;
  final AsyncValue<CertifyDay> day;
  final bool twoColumn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;
    final CertifySignController controller = ref.read(certifySignControllerProvider.notifier);
    final bool notReady = day.value?.status == CertifyStatus.notReady;

    // Figma `1102:817`: `Driver Signature` sarlavhasi va `Use my signature`
    // tugmasi **bitta qatorda** — sarlavha chapda, tugma o'ngda (#B-25).
    final Widget signatureHeader = Row(
      children: <Widget>[
        Expanded(
          child: Text(
            l10n.certifyDriverSignature,
            style: context.text.body8.copyWith(color: c.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (state.hasSavedSignature) ...<Widget>[
          const SizedBox(width: Spacing.s10),
          AppChip(
            label: l10n.certifyUseMySignature,
            selected: state.useSaved,
            onTap: controller.toggleUseSaved,
          ),
        ],
      ],
    );

    final Widget pad = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        signatureHeader,
        if (!state.useSaved) ...<Widget>[
          const SizedBox(height: Spacing.s10),
          SignaturePad(
            clearLabel: l10n.certifyClear,
            saveLabel: l10n.certifySave,
            hint: l10n.certifySignHint,
            onSaved: controller.setSignature,
          ),
        ],
        const SizedBox(height: Spacing.s10),
        _CertifyCheckboxRow(
          checked: state.remember,
          onTap: controller.toggleRemember,
          label: l10n.certifySaveMySignature,
        ),
        const SizedBox(height: Spacing.s10),
        // Figma: huquqiy matn imzo maydonidan **keyin**, tasdiqlash
        // checkbox'i bilan birga (#B-25).
        _CertifyCheckboxRow(
          checked: state.agreed,
          onTap: controller.toggleAgree,
          label: l10n.certifyLegalText,
          multiline: true,
        ),
        if (state.error != null) ...<Widget>[
          const SizedBox(height: Spacing.s10),
          Text(
            localizedApiError(l10n, state.error!),
            style: context.text.body16.copyWith(color: c.error),
          ),
        ],
      ],
    );

    // Figma etalonida bir nechta kun tanlangan holat aks ettirilmagan —
    // faqat M126 (bir nechta kunni bitta imzo bilan sertifikatsiyalash)
    // amalga oshirilganda ko'rinadi, aks holda hech narsa chizilmaydi.
    final Widget? summary = state.dates.length > 1
        ? Padding(
            padding: const EdgeInsets.only(bottom: Spacing.s15),
            child: Text(
              l10n.certifyDaysSummary(state.dates.length),
              style: context.text.body16.copyWith(color: c.textSecondary),
            ),
          )
        : null;

    Future<void> confirm() async {
      final CertifyOutcome? outcome = await controller.confirm();
      if (!context.mounted || outcome == null) {
        return;
      }
      final String message = outcome.isFullSuccess
          ? l10n.certifyQueuedMessage
          : l10n.certifyPartialFailure(outcome.failed.length, outcome.total);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      ref.read(certifyListControllerProvider.notifier).clear();
      await Navigator.of(context).maybePop();
    }

    final Widget buttons = Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s15),
      child: Row(
        children: <Widget>[
          // Figma `1102:817`: `Confirm` `Cancel`dan biroz kengroq (~45/50 nisbat).
          Expanded(
            flex: 9,
            child: AppButton.secondary(
              label: l10n.commonCancel,
              onPressed: () => Navigator.of(context).maybePop(),
              expand: true,
            ),
          ),
          const SizedBox(width: Spacing.s10),
          Expanded(
            flex: 10,
            child: AppButton.primary(
              label: notReady ? l10n.certifyBadgeNotReady : l10n.certifyConfirm,
              busy: state.submitting,
              onPressed: state.canConfirm && !notReady ? confirm : null,
              expand: true,
            ),
          ),
        ],
      ),
    );

    final List<Widget> content = <Widget>[
      if (summary != null) ...<Widget>[summary, const SizedBox(height: Spacing.s20)],
      pad,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: twoColumn
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(child: summary ?? const SizedBox.shrink()),
                    ),
                    const SizedBox(width: Spacing.s20),
                    Expanded(child: SingleChildScrollView(child: pad)),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: Spacing.s20),
                  children: content,
                ),
        ),
        buttons,
      ],
    );
  }
}

/// Figma dagi sertifikatsiya checkbox qatori (#B-25): chapda `AppCheckbox`,
/// o'ngda matn. Uzun huquqiy matn uchun [multiline] bilan yuqoriga tekislanadi.
class _CertifyCheckboxRow extends StatelessWidget {
  const _CertifyCheckboxRow({
    required this.checked,
    required this.onTap,
    required this.label,
    this.multiline = false,
  });

  final bool checked;
  final VoidCallback onTap;
  final String label;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.s5),
        child: Row(
          crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: <Widget>[
            AppCheckbox(value: checked, onChanged: (bool _) => onTap()),
            const SizedBox(width: Spacing.s10),
            Expanded(
              child: Text(label, style: context.text.body14.copyWith(color: c.textPrimary)),
            ),
          ],
        ),
      ),
    );
  }
}
