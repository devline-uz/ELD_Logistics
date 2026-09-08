/// `context.l10n` kengaytmasi — barcha foydalanuvchi matni faqat shu orqali.
library;

import 'package:flutter/widgets.dart';

import '../../l10n/generated/app_localizations.dart';

export '../../l10n/generated/app_localizations.dart' show AppLocalizations;

extension L10nExtension on BuildContext {
  /// Joriy lokal uchun tarjimalar. Hard-coded matn taqiq (CI grep).
  AppLocalizations get l10n => AppLocalizations.of(this);
}
