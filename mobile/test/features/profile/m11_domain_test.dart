@Timeout(Duration(seconds: 60))
/// M11 domen qoidalari (widget emas): profil hosilalari, versiya taqqoslash,
/// feedback va ticket validatsiyasi.
library;

import 'package:eld_mobile/features/feedback/domain/feedback_draft.dart';
import 'package:eld_mobile/features/profile/domain/app_config_info.dart';
import 'package:eld_mobile/features/support/domain/support_ticket.dart';
import 'package:eld_mobile/features/support/domain/ticket_draft.dart';
import 'package:flutter_test/flutter_test.dart';

import 'm11_test_harness.dart';

void main() {
  group('DriverProfile', () {
    test('initials — ism va familiya bosh harflari', () {
      expect(buildTestProfile().initials, 'AK');
      expect(buildTestProfile().fullName, 'Alex Kim');
    });

    test('has() — RBAC tekshiruvi', () {
      final bool ok = buildTestProfile(
        permissions: const <String>['support.read'],
      ).has('support.read');
      expect(ok, isTrue);
      expect(buildTestProfile(permissions: const <String>[]).has('support.read'), isFalse);
    });
  });

  group('AppConfigInfo.isNewerThan', () {
    test('kattaroq versiya — true', () {
      expect(const AppConfigInfo(latestVersion: '1.4.2').isNewerThan('1.4.1'), isTrue);
      expect(const AppConfigInfo(latestVersion: '2.0.0').isNewerThan('1.9.9'), isTrue);
    });

    test('teng yoki kichik — false', () {
      expect(const AppConfigInfo(latestVersion: '1.4.2').isNewerThan('1.4.2'), isFalse);
      expect(const AppConfigInfo(latestVersion: '1.4.0').isNewerThan('1.4.2'), isFalse);
    });

    test('`latest_version` yo\'q — false', () {
      expect(const AppConfigInfo().isNewerThan('1.0.0'), isFalse);
    });

    test('build qo\'shimchasi (`1.4.2+7`) e\'tiborga olinmaydi', () {
      expect(const AppConfigInfo(latestVersion: '1.4.2+7').isNewerThan('1.4.2'), isFalse);
    });
  });

  group('FeedbackDraft', () {
    test('baho majburiy (1…5)', () {
      expect(const FeedbackDraft().validate(), <FeedbackValidationError>[
        FeedbackValidationError.ratingRequired,
      ]);
      expect(const FeedbackDraft(rating: 0).isValid, isFalse);
      expect(const FeedbackDraft(rating: 6).isValid, isFalse);
      expect(const FeedbackDraft(rating: 5).isValid, isTrue);
    });

    test('payload — `app_rating` + trimlangan `text`', () {
      expect(const FeedbackDraft(rating: 4, text: '  hi  ').toPayload(), <String, Object?>{
        'app_rating': 4,
        'text': 'hi',
      });
    });
  });

  group('TicketDraft', () {
    test('`subject` majburiy', () {
      expect(
        const TicketDraft(subject: '   ').validate(),
        contains(TicketValidationError.subjectRequired),
      );
      expect(const TicketDraft(subject: 'x').isValid, isTrue);
    });

    test('M114: biriktirmalar ≤3', () {
      const TicketDraft draft = TicketDraft(
        subject: 'x',
        attachments: <String>['a', 'b', 'c', 'd'],
      );
      expect(draft.validate(), contains(TicketValidationError.tooManyAttachments));
    });

    test('M164: payload da `company_id` yo\'q', () {
      final Map<String, Object?> payload = const TicketDraft(subject: 'x').toPayload();
      expect(payload.containsKey('company_id'), isFalse);
      expect(payload['contact_on'], 'email');
    });
  });

  group('SupportTicket', () {
    test('displayNumber — backend raqami yoki `id` oxiri', () {
      expect(buildTestTicket().displayNumber, '122546');
      expect(
        const SupportTicket(
          id: 'abcdef1234',
          status: TicketStatus.newly,
          subject: 's',
        ).displayNumber,
        'ef1234',
      );
    });

    test('M115: noma\'lum holat `new` ga tushadi', () {
      expect(TicketStatus.fromWire('weird'), TicketStatus.newly);
      expect(TicketStatus.fromWire('in_progress'), TicketStatus.inProgress);
    });
  });
}
