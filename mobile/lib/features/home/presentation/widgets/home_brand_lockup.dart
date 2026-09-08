/// `M-09` app bar'idagi logotip lockup — «One» `primary`, «Book ELD»
/// `textPrimary` (Figma `2177:12192`, matn tuguni #60).
///
/// Brend nomi M90 bo'yicha **`OneBook ELD`** — bo'linish faqat vizual.
library;

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';

class HomeBrandLockup extends StatelessWidget {
  const HomeBrandLockup({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppLocalizations l10n = context.l10n;
    return Semantics(
      header: true,
      label: l10n.appTitle,
      child: ExcludeSemantics(
        child: RichText(
          text: TextSpan(
            style: context.text.body8.copyWith(color: c.textPrimary),
            children: <InlineSpan>[
              TextSpan(
                text: l10n.homeBrandOne,
                style: TextStyle(color: c.primary),
              ),
              TextSpan(text: l10n.homeBrandRest),
            ],
          ),
        ),
      ),
    );
  }
}
