/// Marshrut yo'llari — string literal tarqatish taqiq.
library;

abstract final class AppRoute {
  const AppRoute._();

  static const String splash = '/';
  static const String login = '/login';
  static const String pin = '/pin';

  // Asosiy tab'lar (StatefulShellRoute.indexedStack).
  static const String home = '/home';
  static const String logs = '/logs';
  static const String chat = '/chat';
  static const String profile = '/profile';

  /// Komponentlar katalogi — faqat debug (`Env.devMenuVisible`).
  static const String devComponents = '/dev/components';

  /// Qo'riqchi tekshirmaydigan `core` yo'llari.
  ///
  /// `devComponents` bu yerda xavfsiz: marshrutning o'zi faqat `Env.devMenuVisible`
  /// bo'lganda ro'yxatga olinadi, prod build'da umuman mavjud emas.
  ///
  /// Auth modulining login'dan oldingi ekranlari `AuthRoute.publicPaths` da;
  /// qo'riqchi (`app_router.dart`) ikkala to'plamning birlashmasini ishlatadi.
  static const Set<String> publicPaths = <String>{splash, login, devComponents};
}
