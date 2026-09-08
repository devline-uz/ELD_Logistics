/// `SyncIndicator` — app bar'dagi sinxronizatsiya ikonkasi (tz-mobile §11.0.4).
///
/// Holatlar: `idle` · `syncing` (aylanish) · `error` (`error` nuqta) ·
/// `offline` (navbatdagi yozuvlar soni). Matn (tooltip) parametr sifatida.
library;

import 'package:flutter/material.dart';

import '../spacing.dart';
import '../theme.dart';
import '../tokens.dart';

enum SyncStatus {
  /// Hammasi yuborilgan.
  idle,

  /// Push/pull ketmoqda.
  syncing,

  /// Oxirgi urinish xato bilan tugadi.
  error,

  /// Tarmoq yo'q — outbox to'planmoqda.
  offline,
}

class SyncIndicator extends StatefulWidget {
  const SyncIndicator({
    required this.status,
    this.onPressed,
    this.tooltip,
    this.pendingCount = 0,
    super.key,
  });

  final SyncStatus status;
  final VoidCallback? onPressed;

  /// Lokalizatsiya qilingan tooltip.
  final String? tooltip;

  /// Outbox'dagi yozuvlar soni (0 — badge chizilmaydi).
  final int pendingCount;

  @override
  State<SyncIndicator> createState() => _SyncIndicatorState();
}

class _SyncIndicatorState extends State<SyncIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  @override
  void initState() {
    super.initState();
    _apply();
  }

  @override
  void didUpdateWidget(SyncIndicator old) {
    super.didUpdateWidget(old);
    if (old.status != widget.status) {
      _apply();
    }
  }

  void _apply() {
    if (widget.status == SyncStatus.syncing) {
      _spin.repeat();
    } else {
      _spin.stop();
      _spin.value = 0;
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final (IconData icon, Color color) = switch (widget.status) {
      SyncStatus.idle => (Icons.refresh, c.textSecondary),
      SyncStatus.syncing => (Icons.refresh, c.primary),
      SyncStatus.error => (Icons.sync_problem, c.error),
      SyncStatus.offline => (Icons.cloud_off_outlined, c.warningDark),
    };

    Widget child = Icon(icon, color: color, size: Spacing.s25);
    if (widget.status == SyncStatus.syncing) {
      child = RotationTransition(turns: _spin, child: child);
    }

    return Semantics(
      button: widget.onPressed != null,
      label: widget.tooltip,
      child: IconButton(
        onPressed: widget.onPressed,
        tooltip: widget.tooltip,
        icon: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            child,
            if (widget.status == SyncStatus.error || widget.pendingCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: Spacing.s10,
                  height: Spacing.s10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.status == SyncStatus.error ? c.error : c.warning,
                    border: Border.all(color: c.surface, width: Strokes.thin),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
