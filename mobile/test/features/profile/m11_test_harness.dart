/// M11 klasteri (M-44…M-53) uchun umumiy test qobig'i.
///
/// Tarmoq, Drift va outbox'ga umuman tegilmaydi — hamma narsa domen
/// interfeyslari darajasida override qilinadi (M5). Qobiq `profile` da
/// turadi, chunki `settings`/`legal`/`feedback`/`support` shu klasterning
/// bir qismi va bir xil provayderlarni ulashadi.
library;

import 'dart:async';

import 'package:eld_mobile/core/device/app_version.dart';
import 'package:eld_mobile/core/error/api_error.dart';
import 'package:eld_mobile/core/ui/components/app_button.dart';
import 'package:eld_mobile/core/ui/theme.dart';
import 'package:eld_mobile/features/auth/data/auth_providers.dart';
import 'package:eld_mobile/features/feedback/data/feedback_repository_impl.dart';
import 'package:eld_mobile/features/feedback/domain/feedback_draft.dart';
import 'package:eld_mobile/features/feedback/domain/feedback_repository.dart';
import 'package:eld_mobile/features/profile/data/profile_repository_impl.dart';
import 'package:eld_mobile/features/profile/domain/app_config_info.dart';
import 'package:eld_mobile/features/profile/domain/driver_profile.dart';
import 'package:eld_mobile/features/profile/domain/m11_permissions.dart';
import 'package:eld_mobile/features/profile/domain/profile_repository.dart';
import 'package:eld_mobile/features/profile/domain/submit_outcome.dart';
import 'package:eld_mobile/features/support/data/support_repository_impl.dart';
import 'package:eld_mobile/features/support/domain/support_repository.dart';
import 'package:eld_mobile/features/support/domain/support_ticket.dart';
import 'package:eld_mobile/features/support/domain/ticket_draft.dart';
import 'package:eld_mobile/l10n/generated/app_localizations.dart';
import 'package:eld_mobile/l10n/generated/app_localizations_en.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Oflayn (tarmoqsiz) xato — `SubmitOutcome.queued` yo'lini sinash uchun.
const ApiError kOfflineError = ApiError(code: 'CLIENT_NETWORK', message: 'offline');

/// Server xatosi.
const ApiError kServerError = ApiError(code: 'INTERNAL', message: 'boom');

/// Barcha M11 huquqlari bor namunaviy haydovchi.
DriverProfile buildTestProfile({
  List<String> permissions = const <String>[
    kPermFeedbackCreate,
    kPermSupportRead,
    kPermSupportCreate,
  ],
  String? unitNumber = '1021',
  String? phone = '+1 555 0100',
  String? licenseNumber = 'D1234567',
  String? licenseState = 'TX',
}) => DriverProfile(
  id: 'drv-1',
  firstName: 'Alex',
  lastName: 'Kim',
  email: 'alex.kim@example.com',
  username: 'akim',
  unitNumber: unitNumber,
  phone: phone,
  licenseNumber: licenseNumber,
  licenseState: licenseState,
  pinSet: true,
  permissions: permissions,
);

SupportTicket buildTestTicket({
  String id = 'tkt-122546',
  TicketStatus status = TicketStatus.newly,
  String subject = 'Log grid does not refresh',
}) => SupportTicket(
  id: id,
  number: '122546',
  status: status,
  subject: subject,
  description: 'After certifying a day the grid stays stale until restart.',
  contactOn: ContactChannel.email,
  createdAt: DateTime.utc(2025, 5, 28, 14, 24),
  messageCount: 1,
);

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({this.profile, this.error, this.logoutError, this.gate});

  DriverProfile? profile;
  ApiError? error;
  ApiError? logoutError;

  /// Berilsa `load()` shu `Completer` tugaguncha osilib turadi —
  /// yuklanish holatini (skeleton) tekshirish uchun.
  Completer<void>? gate;

  final List<String> calls = <String>[];

  @override
  Future<DriverProfile> load() async {
    calls.add('load');
    if (gate != null) {
      await gate!.future;
    }
    if (error != null) {
      throw error!;
    }
    return profile ?? buildTestProfile();
  }

  @override
  Future<void> logout() async {
    calls.add('logout');
    if (logoutError != null) {
      throw logoutError!;
    }
  }
}

class FakeAppConfigRepository implements AppConfigRepository {
  FakeAppConfigRepository({this.config, this.error});

  AppConfigInfo? config;
  ApiError? error;
  final List<String> calls = <String>[];

  @override
  Future<AppConfigInfo> load() async {
    calls.add('load');
    if (error != null) {
      throw error!;
    }
    return config ?? const AppConfigInfo(latestVersion: '1.0.0', supportEmail: 'help@example.com');
  }
}

class FakeFeedbackRepository implements FeedbackRepository {
  FakeFeedbackRepository({this.outcome = SubmitOutcome.sent, this.error});

  SubmitOutcome outcome;
  ApiError? error;
  final List<FeedbackDraft> submitted = <FeedbackDraft>[];

  @override
  Future<SubmitOutcome> submit(FeedbackDraft draft) async {
    submitted.add(draft);
    if (error != null) {
      throw error!;
    }
    return outcome;
  }
}

class FakeSupportRepository implements SupportRepository {
  FakeSupportRepository({
    this.tickets = const <SupportTicket>[],
    this.messages = const <SupportMessage>[],
    this.createOutcome = SubmitOutcome.sent,
    this.replyOutcome = SubmitOutcome.sent,
  });

  List<SupportTicket> tickets;
  List<SupportMessage> messages;
  SubmitOutcome createOutcome;
  SubmitOutcome replyOutcome;

  ApiError? listError;
  ApiError? threadError;
  ApiError? createError;
  ApiError? replyError;

  final List<String> calls = <String>[];
  final List<TicketDraft> created = <TicketDraft>[];

  @override
  Future<List<SupportTicket>> list() async {
    calls.add('list');
    if (listError != null) {
      throw listError!;
    }
    return tickets;
  }

  @override
  Future<TicketThread> thread(String id) async {
    calls.add('thread:$id');
    if (threadError != null) {
      throw threadError!;
    }
    return TicketThread(
      ticket: tickets.isEmpty ? buildTestTicket(id: id) : tickets.first,
      messages: messages,
    );
  }

  @override
  Future<SubmitOutcome> create(TicketDraft draft) async {
    calls.add('create');
    created.add(draft);
    if (createError != null) {
      throw createError!;
    }
    return createOutcome;
  }

  @override
  Future<SubmitOutcome> reply({required String ticketId, required String text}) async {
    calls.add('reply:$ticketId:$text');
    if (replyError != null) {
      throw replyError!;
    }
    return replyOutcome;
  }
}

/// M11 provayderlarining test override'lari.
List<Override> m11Overrides({
  FakeProfileRepository? profile,
  FakeAppConfigRepository? config,
  FakeFeedbackRepository? feedback,
  FakeSupportRepository? support,
}) => <Override>[
  profileRepositoryProvider.overrideWithValue(profile ?? FakeProfileRepository()),
  appConfigRepositoryProvider.overrideWithValue(config ?? FakeAppConfigRepository()),
  feedbackRepositoryProvider.overrideWithValue(feedback ?? FakeFeedbackRepository()),
  supportRepositoryProvider.overrideWithValue(support ?? FakeSupportRepository()),
  // `package_info_plus` test muhitida yo'q — versiya qotirilgan (golden ham).
  resolvedAppVersionProvider.overrideWithValue(
    const AppVersion(version: '1.0.0', buildNumber: '42', packageName: 'uz.onebook.eld'),
  ),
];

/// M11 ekranini to'liq ilova kontekstida (tema, l10n, DI, router) ko'taradi.
///
/// [routes] berilmasa ekran yagona `/` marshrutida chiziladi — `context.push`
/// ishlashi uchun kerakli bolalar marshrutlari qo'shiladi.
Future<void> pumpM11Screen(
  WidgetTester tester,
  Widget screen, {
  List<Override> overrides = const <Override>[],
  List<RouteBase> extraRoutes = const <RouteBase>[],
  Size surface = const Size(393, 852),
  Brightness brightness = Brightness.light,
}) async {
  // `dpr=3` da mantiqiy kenglik 131 dp ga tushib ketardi — aniq 1 ga qo'yiladi.
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = surface;
  addTearDown(tester.view.reset);

  final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (BuildContext context, GoRouterState state) => screen),
      ...extraRoutes,
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        theme: AppTheme.of(brightness),
        localizationsDelegates: const <LocalizationsDelegate<Object?>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await settle(tester);
}

/// `pumpAndSettle` emas: skeleton/spinner cheksiz animatsiya beradi.
Future<void> settle(WidgetTester tester, {int frames = 6}) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

/// Ro'yxatni [finder] ko'ringuncha suradi (`ListView` bolalarni dangasa
/// quradi — ekrandan tashqaridagi band umuman `build` bo'lmaydi).
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isNotEmpty) {
    return;
  }
  await tester.scrollUntilVisible(finder, 120, scrollable: find.byType(Scrollable).first);
  await settle(tester);
}

/// `AppButton.primary/...` yopiq subklass qaytaradi — `find.byType(AppButton)`
/// hech qachon topmaydi.
Finder appButtons() => find.bySubtype<AppButton>();

Finder appButton(String label) =>
    find.ancestor(of: find.text(label), matching: find.bySubtype<AppButton>());

/// Test uchun l10n (kalitlarni qattiq yozmaslik uchun).
AppLocalizations get l10n => AppLocalizationsEn();
