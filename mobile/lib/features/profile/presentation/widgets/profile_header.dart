/// `M-44` sarlavha bloki (Figma `1119:445`): avatar + ism/unit + kontakt + litsenziya.
///
/// O'lchovlar Figma dan: avatar 48×48 `r24`, bosh harflar 16 Bold; ism qatori
/// 16 Bold markazda; kontakt va litsenziya qatorlari 14 Medium `textSecondary`.
///
/// TODO(D-26): Figma da ism `Satoshi Variable Bold 16` — litsenziya yo'q,
/// `typography.body11` (Bold 16) eng yaqin token.
/// TODO(D-29): avatar foni Figma da `#353945` (Neutral 8) — `AppColors` da
/// bunday token yo'q. Ikkala temada kontrast saqlanishi uchun `textPrimary`
/// (light `#23262F`, dark `#FCFCFD`) fon va `bg` matn sifatida olinadi.
library;

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/driver_profile.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.profile, super.key});

  final DriverProfile profile;

  /// Figma: `Frame 1321317381` 48×48.
  static const double avatarSize = 48;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppLocalizations l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Center(
          child: Semantics(
            label: profile.fullName,
            child: Container(
              width: avatarSize,
              height: avatarSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: c.textPrimary, shape: BoxShape.circle),
              child: Text(profile.initials, style: context.text.body11.copyWith(color: c.bg)),
            ),
          ),
        ),
        const SizedBox(height: Spacing.s10),
        Text(
          l10n.profileNameLine(profile.fullName, AppFormats.orNa(profile.unitNumber)),
          textAlign: TextAlign.center,
          style: context.text.body11.copyWith(color: c.textPrimary),
        ),
        const SizedBox(height: Spacing.s5),
        Text(
          l10n.profileContactLine(AppFormats.orNa(profile.email), AppFormats.orNa(profile.phone)),
          textAlign: TextAlign.center,
          style: context.text.body14.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: Spacing.s5),
        Text(
          l10n.profileLicenseLine(
            AppFormats.orNa(profile.licenseNumber),
            AppFormats.orNa(profile.licenseState),
          ),
          textAlign: TextAlign.center,
          style: context.text.body14.copyWith(color: c.textSecondary),
        ),
      ],
    );
  }
}
