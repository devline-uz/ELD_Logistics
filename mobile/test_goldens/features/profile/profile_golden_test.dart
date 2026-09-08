@Timeout(Duration(seconds: 60))
/// **M-44 Profile** goldenlari — light/dark × phone/tablet.
///
/// Figma `1119-445` da ekran pastida `BNB-19` navigatsiyasi (`Profile` faol
/// `primary` chip) ko'rinadi — u ilovada shell marshrutdan keladi, shu sababli
/// golden shu yerda ham shell bilan birga chiziladi.
library;

import 'package:eld_mobile/core/i18n/l10n_extension.dart';
import 'package:eld_mobile/core/ui/ui.dart';
import 'package:eld_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test/features/profile/m11_test_harness.dart';
import '../golden_screen_host.dart';

/// `_MainShell` ning golden ekvivalenti (`core/router` ga tegilmaydi).
class _ProfileWithNav extends StatelessWidget {
  const _ProfileWithNav();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: const ProfileScreen(),
    bottomNavigationBar: AppNavBar(
      currentIndex: 3,
      onSelected: (int _) {},
      items: <AppNavItem>[
        AppNavItem(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: context.l10n.navHome,
        ),
        AppNavItem(
          icon: Icons.article_outlined,
          selectedIcon: Icons.article,
          label: context.l10n.navLogs,
        ),
        AppNavItem(
          icon: Icons.chat_bubble_outline,
          selectedIcon: Icons.chat_bubble,
          label: context.l10n.navChat,
        ),
        AppNavItem(
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          label: context.l10n.navProfile,
        ),
      ],
    ),
  );
}

void main() {
  screenGoldenMatrix('profile', builder: () => const _ProfileWithNav(), overrides: m11Overrides);
}
