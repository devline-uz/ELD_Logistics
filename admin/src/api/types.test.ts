import { describe, expect, it } from 'vitest';

import { DEFAULT_PER_PAGE, PER_PAGE_OPTIONS } from './types';
import type * as T from './types';

/**
 * Alias haqiqiy sxemaga yechildimi? `unknown`/`any`/`never` — yechilmagan.
 * (`unknown extends X` faqat `X` `unknown` yoki `any` bo'lganda `true`.)
 */
type Resolved<X> = unknown extends X ? false : [X] extends [never] ? false : true;

/** Kompilyatsiya vaqtidagi tasdiq: `Expect<Resolved<X>>` faqat `true` da o'tadi. */
type Expect<X extends true> = X;

/* Har bir domen uchun kamida bitta alias — `unknown` qolmaganini isbotlaydi. */
export type AliasChecks = [
  // auth / session
  Expect<Resolved<T.LoginResult>>,
  Expect<Resolved<T.Tokens>>,
  Expect<Resolved<T.SessionInfo>>,
  Expect<Resolved<T.Profile>>,
  Expect<Resolved<T.AppConfig>>,
  Expect<Resolved<T.TotpSetup>>,
  // users / roles / permissions
  Expect<Resolved<T.User>>,
  Expect<Resolved<T.Role>>,
  Expect<Resolved<T.Permission>>,
  Expect<Resolved<T.PermissionModule>>,
  // company / branch / settings
  Expect<Resolved<T.Company>>,
  Expect<Resolved<T.AdminCompany>>,
  Expect<Resolved<T.Branch>>,
  Expect<Resolved<T.HosPolicy>>,
  Expect<Resolved<T.NotificationSetting>>,
  // fleet
  Expect<Resolved<T.Unit>>,
  Expect<Resolved<T.Trailer>>,
  Expect<Resolved<T.EldDevice>>,
  Expect<Resolved<T.ShippingDocument>>,
  // drivers
  Expect<Resolved<T.Driver>>,
  Expect<Resolved<T.DriverLicense>>,
  Expect<Resolved<T.CoDriver>>,
  // logs
  Expect<Resolved<T.DailyLogSummary>>,
  Expect<Resolved<T.DailyLogDetail>>,
  Expect<Resolved<T.LogEvent>>,
  Expect<Resolved<T.LogEditRequest>>,
  Expect<Resolved<T.UnidentifiedEvent>>,
  Expect<Resolved<T.Violation>>,
  // duty / hos
  Expect<Resolved<T.HosSummary>>,
  Expect<Resolved<T.DutyStatusEvent>>,
  // dvir
  Expect<Resolved<T.DvirReport>>,
  Expect<Resolved<T.DvirDefect>>,
  Expect<Resolved<T.DefectType>>,
  // maintenance
  Expect<Resolved<T.MaintenanceRecord>>,
  Expect<Resolved<T.MaintenanceSchedule>>,
  // tracking / trips
  Expect<Resolved<T.LiveUnit>>,
  Expect<Resolved<T.Trip>>,
  Expect<Resolved<T.TripDetail>>,
  // routes
  Expect<Resolved<T.Route>>,
  Expect<Resolved<T.Waypoint>>,
  // reports / export
  Expect<Resolved<T.ActivityRow>>,
  Expect<Resolved<T.ExportJob>>,
  // dashboard
  Expect<Resolved<T.DashboardSummary>>,
  // chat
  Expect<Resolved<T.ChatThread>>,
  Expect<Resolved<T.ChatMessage>>,
  // notifications
  Expect<Resolved<T.Notification>>,
  // support
  Expect<Resolved<T.SupportTicket>>,
  Expect<Resolved<T.Feedback>>,
  // audit
  Expect<Resolved<T.AuditLogEntry>>,
  // files
  Expect<Resolved<T.PresignRequest>>,
  Expect<Resolved<T.PresignResponse>>,
  // umumiy konvertlar
  Expect<Resolved<T.ListMeta>>,
  Expect<Resolved<T.CursorMeta>>,
  Expect<Resolved<T.ErrorBody>>,
  Expect<Resolved<T.FieldError>>,
];

/* Ro'yxat konverti haqiqiy javob shakliga mos kelishi. */
export type EnvelopeChecks = [
  Expect<
    T.ListResponse<T.Unit> extends {
      data?: T.Unit[];
      meta?: { page?: number; per_page?: number; total?: number };
    }
      ? true
      : false
  >,
  // Generatsiya qilingan `UnitListEnvelope` qo'lda yozilgan konvertga mos.
  Expect<
    T.components['schemas']['github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitListEnvelope'] extends T.ListResponse<T.Unit>
      ? true
      : false
  >,
];

describe('api/types', () => {
  it('per_page faqat 10/25/50', () => {
    expect(PER_PAGE_OPTIONS).toEqual([10, 25, 50]);
  });

  it('default per_page — 25', () => {
    expect(DEFAULT_PER_PAGE).toBe(25);
  });
});
