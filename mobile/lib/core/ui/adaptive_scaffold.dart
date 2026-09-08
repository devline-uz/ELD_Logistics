/// Telefon/planshet ajratish (tz-mobile §3, M6/M7).
///
/// **Qoida:** har ekranda bitta `Controller` + ikkita `View`. Biznes mantiq
/// `PhoneView`/`TabletView` da takrorlanmaydi — ular faqat chizadi.
/// Qurilma turi `MediaQuery.size.width` dan emas, `DeviceProfile` dan olinadi.
library;

import 'package:flutter/material.dart';

import '../device/device_profile.dart';
import 'spacing.dart';

/// Profilga qarab ikki ko'rinishdan birini tanlaydi.
///
/// ```dart
/// AdaptiveView(
///   phone: (BuildContext c) => HomePhoneView(state: state),
///   tablet: (BuildContext c) => HomeTabletView(state: state),
/// )
/// ```
class AdaptiveView extends StatelessWidget {
  const AdaptiveView({required this.phone, required this.tablet, super.key});

  final WidgetBuilder phone;
  final WidgetBuilder tablet;

  @override
  Widget build(BuildContext context) =>
      DeviceProfile.of(context).isTablet ? tablet(context) : phone(context);
}

/// Profil bo'yicha qiymat tanlash (padding, teginish maydoni va h.k.).
T adaptiveValue<T>(BuildContext context, {required T phone, required T tablet}) =>
    DeviceProfile.of(context).isTablet ? tablet : phone;

/// Ekran gorizontal padding'i: telefon 16, planshet 24.
double screenPaddingH(BuildContext context) => adaptiveValue<double>(
  context,
  phone: Spacing.screenPaddingPhone,
  tablet: Spacing.screenPaddingTablet,
);

/// Minimal teginish maydoni (M8). [driving] — haydash rejimi (≥64 dp).
double touchTarget(BuildContext context, {bool driving = false}) => driving
    ? TouchTarget.driving
    : adaptiveValue<double>(context, phone: TouchTarget.phone, tablet: TouchTarget.tablet);

/// Planshetda ekran tanasining maksimal kengligi (#B-64).
///
/// 1366 dp landshaftda bir ustunli forma/ro'yxat butun ekran bo'ylab cho'zilsa
/// o'qish qiyinlashadi va Figma proporsiyalari buziladi. Shu sabab tana
/// markazlashtirilib cheklanadi.
abstract final class ContentWidth {
  /// Bir ustunli forma, sozlamalar, ro'yxat.
  static const double single = 720;

  /// Ikki ustunli tarkib yoki keng jadval.
  static const double wide = 1040;

  /// Cheklovsiz — uch ustunli dashboard, log grid, xarita.
  static const double unbounded = double.infinity;
}

/// Tanani markazlashtirib, kengligini [maxWidth] bilan cheklaydi (#B-64).
///
/// Telefonda (`DeviceProfile.phone`) **hech narsa qilmaydi** — telefon
/// layout'i va goldenlari o'zgarmaydi. [maxWidth] `unbounded` bo'lsa ham
/// widget shaffof.
///
/// ```dart
/// // Ekranga ulash — bitta qator:
/// AdaptiveScaffold(maxContentWidth: ContentWidth.single, phone: ..., tablet: ...)
/// ```
class ContentMaxWidth extends StatelessWidget {
  const ContentMaxWidth({
    required this.child,
    this.maxWidth = ContentWidth.single,
    this.applyOnPhone = false,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  /// `true` — telefonda ham cheklaydi (katta telefonlar uchun kerak emas).
  final bool applyOnPhone;

  @override
  Widget build(BuildContext context) {
    if (!maxWidth.isFinite) {
      return child;
    }
    if (!applyOnPhone && !DeviceProfile.of(context).isTablet) {
      return child;
    }
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// `Scaffold` ustidagi yupqa qatlam: profilga mos padding va ko'rinish.
///
/// Navigatsiya (pastki tab bar) `core/router` shell'ida — bu yerda emas.
class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    required this.phone,
    required this.tablet,
    this.appBar,
    this.banners = const <Widget>[],
    this.bottomBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.applyHorizontalPadding = true,
    this.maxContentWidth = ContentWidth.unbounded,
    super.key,
  });

  /// Telefon ko'rinishi (portret).
  final WidgetBuilder phone;

  /// Planshet ko'rinishi (landshaft).
  final WidgetBuilder tablet;

  final PreferredSizeWidget? appBar;

  /// App bar ostidagi doimiy qatorlar: offline, ELD uzilgan, co-driver.
  final List<Widget> banners;

  final Widget? bottomBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  /// `false` — ko'rinish o'zi padding'ni boshqaradi (masalan to'liq kenglikdagi
  /// gorizontal scroll yoki log grid).
  final bool applyHorizontalPadding;

  /// Planshetda tananing maksimal kengligi (#B-64). Standart — cheklovsiz,
  /// ya'ni mavjud ekranlar layout'i o'zgarmaydi; ekran bir qator qo'shib
  /// (`maxContentWidth: ContentWidth.single`) ulanadi.
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final Widget body = AdaptiveView(phone: phone, tablet: tablet);
    final Widget padded = applyHorizontalPadding
        ? Padding(
            padding: EdgeInsets.symmetric(horizontal: screenPaddingH(context)),
            child: body,
          )
        : body;
    final Widget constrained = ContentMaxWidth(maxWidth: maxContentWidth, child: padded);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      bottomNavigationBar: bottomBar,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ...banners,
            Expanded(child: constrained),
          ],
        ),
      ),
    );
  }
}
