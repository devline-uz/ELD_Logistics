/// **M-52 Privacy Policy** (`/legal/privacy`) va **M-53 Terms of Use**
/// (`/legal/terms`) — Figma `2627:25891` (M-53 uchun TZ §11.1 noto'g'ri node
/// beradi, `tasks.md` «Registrda topilgan xatolar»).
///
/// **❓M117:** huquqiy matnlar buyurtmachidan kelmagan. Matn
/// `assets/legal/<kind>.md` da bo'lsa ko'rsatiladi, aks holda placeholder +
/// `support_email` (`GET /app/config`) va `Contact support` (`M-49`) havolasi.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../../profile/domain/app_config_info.dart';
import '../../../profile/presentation/controllers/app_config_controller.dart';
import '../../../profile/profile_routes.dart';

/// Ko'rsatiladigan huquqiy hujjat.
enum LegalDocumentKind {
  privacy('privacy_policy'),
  terms('terms_of_use');

  const LegalDocumentKind(this.asset);

  /// `assets/legal/<asset>.md`.
  final String asset;

  String get assetPath => 'assets/legal/$asset.md';
}

/// Hujjat matni — bo'lmasa `null` (M117 placeholder ko'rsatiladi).
///
/// Asset ro'yxatga olinmagan bo'lsa `rootBundle` istisno tashlaydi; bu
/// «matn hali yo'q» degani, xato emas.
final FutureProviderFamily<String?, LegalDocumentKind> legalDocumentProvider =
    FutureProvider.family<String?, LegalDocumentKind>((Ref ref, LegalDocumentKind kind) async {
      try {
        final String text = await rootBundle.loadString(kind.assetPath);
        return text.trim().isEmpty ? null : text;
      } on FlutterError {
        return null;
      }
    });

class LegalScreen extends ConsumerWidget {
  const LegalScreen({required this.document, super.key});

  final LegalDocumentKind document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final String title = switch (document) {
      LegalDocumentKind.privacy => l10n.legalPrivacyTitle,
      LegalDocumentKind.terms => l10n.legalTermsTitle,
    };

    return AdaptiveScaffold(
      // #B-64: planshetda tana cheklovsiz cho'zilmaydi.
      maxContentWidth: ContentWidth.single,
      appBar: AppBarPrimary(title: title, leading: const AppBackButton()),
      backgroundColor: context.colors.bg,
      phone: (BuildContext context) => _Body(document: document),
      tablet: (BuildContext context) => _Body(document: document),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.document});

  final LegalDocumentKind document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<String?> text = ref.watch(legalDocumentProvider(document));

    return asyncView<String?>(
      text,
      loading: const Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.s20),
        child: LoadingSkeleton(itemCount: 8),
      ),
      // Asset o'qish xatosi ham «matn yo'q» bilan bir xil ko'rinadi (M117).
      error: (Object _) => const _Placeholder(),
      data: (String? value) => value == null ? const _Placeholder() : _Document(text: value),
    );
  }
}

/// Huquqiy hujjat matni (Figma `2627:25778` / `2627:25891`).
///
/// `#` bilan boshlangan blok — bo'lim sarlavhasi (Bold 16), qolgani
/// `JUSTIFIED` Regular 14 `textSecondary`.
class _Document extends StatelessWidget {
  const _Document({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final List<String> blocks = text
        .split(RegExp(r'\n\s*\n'))
        .map((String b) => b.trim())
        .where((String b) => b.isNotEmpty)
        .toList(growable: false);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s20),
      itemCount: blocks.length,
      separatorBuilder: (BuildContext _, int _) => const SizedBox(height: Spacing.s15),
      itemBuilder: (BuildContext context, int index) {
        final String block = blocks[index];
        final bool heading = block.startsWith('#');
        return Text(
          heading ? block.replaceFirst(RegExp(r'^#+\s*'), '') : block,
          textAlign: heading ? TextAlign.start : TextAlign.justify,
          style: heading
              ? context.text.body11.copyWith(color: context.colors.textPrimary)
              : context.text.body15.copyWith(color: context.colors.textSecondary),
        );
      },
    );
  }
}

/// **M117** — matn kelmaguncha ko'rsatiladigan holat.
class _Placeholder extends ConsumerWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AppConfigInfo? config = ref.watch(appConfigControllerProvider).value;
    final String email = config?.supportEmail ?? AppFormats.orNa(null);

    return EmptyState(
      title: l10n.legalPendingTitle,
      message: l10n.legalPendingMessage(email),
      icon: Icons.description_outlined,
      actionLabel: l10n.legalContactSupport,
      onAction: () => context.push(ProfileRoute.supportNew),
    );
  }
}
