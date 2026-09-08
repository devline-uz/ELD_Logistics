/// **M-48 Give feedback** (`/profile/feedback`) — Figma `1131:1149` (light) /
/// `2665:28031` (dark).
///
/// Ikki savol (TZ §11.8): 1–5 yulduz + erkin matn. **M180:** Figma dagi
/// qolgan savollar boshqa mahsulotga tegishli («OneTime Log», «One-T…») —
/// kodga ko'chirilmaydi.
/// **M113 ✅** Planshetda savol matni «…with the app?» ga o'zgaradi.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../../profile/domain/submit_outcome.dart';
import '../../domain/feedback_draft.dart';
import '../controllers/feedback_controller.dart';
import '../widgets/star_rating.dart';

class FeedbackScreen extends ConsumerWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AdaptiveScaffold(
    // #B-64: planshetda tana cheklovsiz cho'zilmaydi.
    maxContentWidth: ContentWidth.single,
    appBar: AppBarPrimary(title: context.l10n.feedbackTitle, leading: const AppBackButton()),
    backgroundColor: context.colors.bg,
    phone: (BuildContext c) => FeedbackPane(
      tablet: false,
      onDone: () {
        if (c.canPop()) {
          c.pop();
        }
      },
    ),
    tablet: (BuildContext c) => FeedbackPane(
      tablet: true,
      onDone: () {
        if (c.canPop()) {
          c.pop();
        }
      },
    ),
  );
}

/// `M-48` ekrani va `T-24` planshet modali uchun yagona tana (A3).
///
/// Matn kontrolleri va yuborish natijasini kuzatish shu yerda — ekran ham,
/// modal ham buni takrorlamaydi. Yopilish usuli chaqiruvchida ([onDone]):
/// ekranda `go_router` pop, modalda `Navigator.pop`.
class FeedbackPane extends ConsumerStatefulWidget {
  const FeedbackPane({required this.tablet, required this.onDone, super.key});

  final bool tablet;
  final VoidCallback onDone;

  @override
  ConsumerState<FeedbackPane> createState() => _FeedbackPaneState();
}

class _FeedbackPaneState extends ConsumerState<FeedbackPane> {
  final TextEditingController _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    ref.listen<FeedbackFormState>(feedbackControllerProvider, (
      FeedbackFormState? previous,
      FeedbackFormState next,
    ) {
      if (next.outcome != null && previous?.outcome != next.outcome) {
        final String message = next.outcome == SubmitOutcome.queued
            ? l10n.feedbackQueued
            : l10n.feedbackSent;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        widget.onDone();
      }
    });

    return FeedbackBody(text: _text, tablet: widget.tablet);
  }
}

class FeedbackBody extends ConsumerWidget {
  const FeedbackBody({required this.text, required this.tablet, super.key});

  final TextEditingController text;
  final bool tablet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final FeedbackFormState state = ref.watch(feedbackControllerProvider);
    final FeedbackController controller = ref.read(feedbackControllerProvider.notifier);
    final bool ratingMissing =
        state.showErrors && state.errors.contains(FeedbackValidationError.ratingRequired);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: Spacing.s20),
            children: <Widget>[
              Text(
                l10n.feedbackIntro,
                style: context.text.body15.copyWith(color: context.colors.textPrimary),
              ),
              const SizedBox(height: Spacing.s25),
              SettingsCard(
                children: <Widget>[
                  _Question(
                    text: tablet ? l10n.feedbackRatingQuestionTablet : l10n.feedbackRatingQuestion,
                  ),
                  StarRating(
                    value: state.draft.rating,
                    enabled: !state.submitting,
                    onChanged: controller.setRating,
                  ),
                  if (ratingMissing)
                    Text(
                      l10n.feedbackRatingRequired,
                      style: context.text.body16.copyWith(color: context.colors.error),
                    ),
                ],
              ),
              const SizedBox(height: Spacing.s25),
              SettingsCard(
                children: <Widget>[
                  _Question(
                    text: tablet
                        ? l10n.feedbackFeatureQuestionTablet
                        : l10n.feedbackFeatureQuestion,
                  ),
                  AppTextField(
                    controller: text,
                    hint: l10n.feedbackTextHint,
                    minLines: 3,
                    maxLines: 5,
                    enabled: !state.submitting,
                    onChanged: controller.setText,
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
          child: AppButton.primary(
            label: l10n.feedbackSubmit,
            busy: state.submitting,
            onPressed: state.submitting ? null : controller.submit,
          ),
        ),
      ],
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: context.text.body14.copyWith(color: context.colors.textPrimary));
}
