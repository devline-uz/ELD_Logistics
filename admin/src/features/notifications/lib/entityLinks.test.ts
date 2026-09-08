import { describe, expect, it } from 'vitest';

import { resolveNotificationPath } from './entityLinks';

describe('resolveNotificationPath', () => {
  it('links violations to the violation detail screen', () => {
    expect(resolveNotificationPath('violations', 'v1')).toBe('/violations/v1');
  });

  it('links dvir to the DVIR detail screen', () => {
    expect(resolveNotificationPath('dvir', 'd1')).toBe('/dvir/d1');
  });

  it('links log_edit_request to the edit-requests list (no id needed)', () => {
    expect(resolveNotificationPath('log_edit_request', null)).toBe('/logs/edit-requests');
  });

  it('links maintenance_* prefixed types to the maintenance due list', () => {
    expect(resolveNotificationPath('maintenance_overdue', 'm1')).toBe('/maintenance/due');
    expect(resolveNotificationPath('maintenance_upcoming', undefined)).toBe('/maintenance/due');
  });

  it('links chat_message to the chat screen', () => {
    expect(resolveNotificationPath('chat_message', null)).toBe('/chat');
  });

  it('links unidentified_driving to the unassigned driving screen', () => {
    expect(resolveNotificationPath('unidentified_driving', null)).toBe('/logs/unassigned');
  });

  it('returns null when an id-required type has no entity_id', () => {
    expect(resolveNotificationPath('violations', null)).toBeNull();
    expect(resolveNotificationPath('dvir', undefined)).toBeNull();
  });

  it('returns null for unknown entity types without throwing', () => {
    expect(resolveNotificationPath('subscription_expiring', 'x')).toBeNull();
    expect(resolveNotificationPath(undefined, undefined)).toBeNull();
    expect(resolveNotificationPath(null, null)).toBeNull();
  });

  it('is case-insensitive on entity_type', () => {
    expect(resolveNotificationPath('DVIR', 'd1')).toBe('/dvir/d1');
  });
});

it("entity_id ni kodlaydi — ochiq redirect / yo'l traversali bloklanadi", () => {
  expect(resolveNotificationPath('violations', '\\\\evil.com')).toBe('/violations/%5C%5Cevil.com');
  expect(resolveNotificationPath('dvir', '../../admin')).toBe('/dvir/..%2F..%2Fadmin');
});
