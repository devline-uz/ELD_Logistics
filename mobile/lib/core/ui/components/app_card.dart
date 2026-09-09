/// `AppCard` — barcha ekranlarning yagona karta konteyneri (PARITY #B-08…#B-11).
///
/// Figma: fon `#F6F6F6`, **chegara yo'q**, `r12`, ichki padding **20**,
/// kartalar orasi **15** (`Spacing.cardGap`).
library;

import 'package:flutter/material.dart';

import '../radius.dart';
import '../spacing.dart';
import '../theme.dart';
import '../tokens.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding,
    this.onTap,
    this.grouped = false,
    this.semanticLabel,
    super.key,
  });

  final Widget child;

  /// `null` — `Spacing.cardPadding` (20).
  final EdgeInsetsGeometry? padding;

  final VoidCallback? onTap;

  /// `true` — guruhlangan ro'yxat konteyneri (`r16`, ichki padding 0).
  final bool grouped;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final BorderRadius radius = grouped ? Radii.groupRadius : Radii.cardRadius;
    final EdgeInsetsGeometry pad =
        padding ?? (grouped ? EdgeInsets.zero : const EdgeInsets.all(Spacing.cardPadding));

    final Widget content = Padding(padding: pad, child: child);

    return Semantics(
      container: true,
      label: semanticLabel,
      child: Material(
        color: c.cardSurface,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: onTap == null
            ? content
            : InkWell(onTap: onTap, borderRadius: radius, child: content),
      ),
    );
  }
}

/// Vertikal karta ustuni — oraliq `Spacing.cardGap` (15, #B-11).
class AppCardColumn extends StatelessWidget {
  const AppCardColumn({required this.children, this.gap = Spacing.cardGap, super.key});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      for (int i = 0; i < children.length; i++) ...<Widget>[
        if (i > 0) SizedBox(height: gap),
        children[i],
      ],
    ],
  );
}
