/// `AppSegmented` — segmented control (PARITY #B-15).
///
/// Figma: konteyner h **40**, `r8`, fon `#C2C1CD` @20 %, ichki padding **4**;
/// segmentlar **teng enli** (`Expanded`), h 32, `r8`; faol segment
/// `neutralStrong` fon + `onNeutralStrong` matn.
///
/// Matn **parametr** sifatida keladi (`context.l10n.*`).
library;

import 'package:flutter/material.dart';

import '../radius.dart';
import '../theme.dart';
import '../tokens.dart';

/// Konteyner balandligi — Figma 40.
const double kSegmentedHeight = 40;

/// Ichki padding — Figma 4.
const double kSegmentedPadding = 4;

class AppSegmented extends StatelessWidget {
  const AppSegmented({
    required this.segments,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  /// Lokalizatsiya qilingan yorliqlar (odatda 2–3 ta).
  final List<String> segments;

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      height: kSegmentedHeight,
      padding: const EdgeInsets.all(kSegmentedPadding),
      decoration: BoxDecoration(color: c.overlaySoft, borderRadius: Radii.buttonRadius),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < segments.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == selectedIndex,
                label: segments[i],
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelected(i),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == selectedIndex ? c.neutralStrong : c.transparent,
                      borderRadius: Radii.buttonRadius,
                    ),
                    child: Text(
                      segments[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.body14.copyWith(
                        color: i == selectedIndex ? c.onNeutralStrong : c.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
