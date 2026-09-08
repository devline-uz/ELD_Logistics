/// `KeyValueRow` — ikki ustunli kalit/qiymat qatori (PARITY #B-20).
///
/// Figma: yorliq **chapda** (`textSecondary`), qiymat **o'ngda**
/// (`textPrimary`), bir qatorda. Matn **parametr** sifatida keladi.
library;

import 'package:flutter/material.dart';

import '../spacing.dart';
import '../theme.dart';
import '../tokens.dart';

class KeyValueRow extends StatelessWidget {
  const KeyValueRow({
    required this.label,
    required this.value,
    this.valueWidget,
    this.dense = false,
    super.key,
  });

  /// Lokalizatsiya qilingan yorliq.
  final String label;

  /// Lokalizatsiya/formatlangan qiymat (`AppFormats`).
  final String value;

  /// Matn o'rniga widget (badge, ikonka).
  final Widget? valueWidget;

  /// Ro'yxat ichida ixchamroq vertikal padding.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Semantics(
      label: label,
      value: value,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: dense ? Spacing.s5 / 2 : Spacing.s5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(label, style: context.text.body13.copyWith(color: c.textSecondary)),
            ),
            const SizedBox(width: Spacing.s10),
            Flexible(
              child:
                  valueWidget ??
                  Text(
                    value,
                    style: context.text.body13.copyWith(color: c.textPrimary),
                    textAlign: TextAlign.end,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
