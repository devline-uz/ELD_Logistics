/// Ichki ekranlarning `AppBarPrimary.leading` tugmasi (Figma `weui:back-outlined`).
///
/// `M11` klasteri (`profile`, `settings`, `support`, `feedback`, `legal`) shu
/// bitta tugmani ulashadi — nusxa ko'chirilmaydi.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../i18n/l10n_extension.dart';
import '../theme.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: () {
      if (context.canPop()) {
        context.pop();
      }
    },
    tooltip: context.l10n.profileBack,
    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
    color: context.colors.textPrimary,
  );
}
