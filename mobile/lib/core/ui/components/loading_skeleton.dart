/// `LoadingSkeleton` — yuklanish holati (tz-mobile §11.0.5).
///
/// Dizaynda yuklanish ekrani yo'q: ro'yxat/karta uchun shimmer, tugmalarda
/// inline spinner (`AppButton.busy`), sahifada pull-to-refresh.
///
/// Golden testda animatsiya `pumpAndSettle` bilan to'xtamasligi uchun
/// [animate] `false` qilinadi (`SkeletonConfig.animationsEnabled`).
library;

import 'package:flutter/material.dart';

import '../radius.dart';
import '../spacing.dart';
import '../theme.dart';
import '../tokens.dart';

/// Golden test uchun global o'chirgich — animatsiya determinizmi.
abstract final class SkeletonConfig {
  static bool animationsEnabled = true;
}

/// Bitta shimmer bloki.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    required this.width,
    required this.height,
    this.radius = Radii.sm,
    this.animate = true,
    super.key,
  });

  /// `double.infinity` — ota kengligi.
  final double width;
  final double height;
  final double radius;
  final bool animate;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox> with SingleTickerProviderStateMixin {
  /// Animatsiya o'chirilgan bo'lsa umuman yaratilmaydi (`dispose` da ham
  /// tegilmaydi — aks holda `TickerMode` deaktivatsiyalangan daraxtda qidiriladi).
  AnimationController? _controller;

  bool get _animating => widget.animate && SkeletonConfig.animationsEnabled;

  @override
  void initState() {
    super.initState();
    if (_animating) {
      _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
        ..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Widget box = DecoratedBox(
      decoration: BoxDecoration(
        color: c.skeletonBase,
        borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
      ),
      child: SizedBox(width: widget.width, height: widget.height),
    );

    final AnimationController? controller = _controller;
    if (!_animating || controller == null) {
      return box;
    }
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) => DecoratedBox(
        decoration: BoxDecoration(
          color: Color.lerp(c.skeletonBase, c.skeletonHighlight, controller.value)!,
          borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
        ),
        child: SizedBox(width: widget.width, height: widget.height),
      ),
    );
  }
}

/// Ro'yxat uchun karta skeletlari.
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({this.itemCount = 5, this.animate = true, super.key});

  /// Ko'rsatiladigan soxta kartalar soni.
  final int itemCount;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s10),
      itemCount: itemCount,
      separatorBuilder: (BuildContext _, int _) => const SizedBox(height: Spacing.cardGap),
      itemBuilder: (BuildContext context, int _) => Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: Radii.cardRadius,
          border: Border.all(color: c.stroke, width: Strokes.thin),
        ),
        padding: const EdgeInsets.all(Spacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                SkeletonBox(width: 40, height: 40, radius: Radii.pill, animate: animate),
                const SizedBox(width: Spacing.s10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SkeletonBox(width: double.infinity, height: 14, animate: animate),
                      const SizedBox(height: Spacing.s5),
                      SkeletonBox(width: 120, height: 12, animate: animate),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.s15),
            SkeletonBox(width: double.infinity, height: 12, animate: animate),
            const SizedBox(height: Spacing.s5),
            SkeletonBox(width: 180, height: 12, animate: animate),
          ],
        ),
      ),
    );
  }
}
