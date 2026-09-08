import { describe, expect, it } from 'vitest';

import {
  buildNotificationSettingsPayload,
  enforceLockedChannels,
  rowsEqual,
  settingToRow,
  settingsToRows,
  toggleChannel,
  type NotificationMatrixRow,
} from './matrix';

function row(overrides: Partial<NotificationMatrixRow> = {}): NotificationMatrixRow {
  return {
    alertType: 'chat_message',
    enabled: true,
    channels: ['push', 'email'],
    recipientRoles: [],
    ...overrides,
  };
}

describe('settingToRow / settingsToRows', () => {
  it('maps a backend setting to a row', () => {
    expect(
      settingToRow({
        alert_type: 'hos_violation',
        channels: ['push'],
        enabled: true,
        recipient_roles: ['r1'],
      }),
    ).toEqual({
      alertType: 'hos_violation',
      enabled: true,
      channels: ['push'],
      recipientRoles: ['r1'],
    });
  });

  it('defaults missing fields', () => {
    expect(settingToRow({})).toEqual({
      alertType: '',
      enabled: true,
      channels: [],
      recipientRoles: [],
    });
  });

  it('maps a list', () => {
    expect(
      settingsToRows([{ alert_type: 'chat_message' }, { alert_type: 'hos_warning' }]),
    ).toHaveLength(2);
  });
});

describe('rowsEqual', () => {
  it('is order-independent for channels and roles', () => {
    const a = row({ channels: ['push', 'email'], recipientRoles: ['r1', 'r2'] });
    const b = row({ channels: ['email', 'push'], recipientRoles: ['r2', 'r1'] });
    expect(rowsEqual(a, b)).toBe(true);
  });

  it('detects a channel difference', () => {
    expect(rowsEqual(row({ channels: ['push'] }), row({ channels: ['push', 'sms'] }))).toBe(false);
  });

  it('detects an enabled difference', () => {
    expect(rowsEqual(row({ enabled: true }), row({ enabled: false }))).toBe(false);
  });
});

describe('enforceLockedChannels (F148/Q89)', () => {
  it('re-adds push for hos_* types even if removed', () => {
    const locked = row({ alertType: 'hos_violation', channels: ['email'] });
    expect(enforceLockedChannels(locked).channels).toContain('push');
  });

  it('re-adds push for eld_* types', () => {
    const locked = row({ alertType: 'eld_disconnected', channels: [] });
    expect(enforceLockedChannels(locked).channels).toEqual(['push']);
  });

  it('leaves non-locked types untouched', () => {
    const unlocked = row({ alertType: 'chat_message', channels: ['email'] });
    expect(enforceLockedChannels(unlocked).channels).toEqual(['email']);
  });
});

describe('toggleChannel', () => {
  it('adds a channel', () => {
    expect(toggleChannel(row({ channels: ['push'] }), 'sms', true).channels.sort()).toEqual([
      'push',
      'sms',
    ]);
  });

  it('removes a channel', () => {
    expect(toggleChannel(row({ channels: ['push', 'sms'] }), 'sms', false).channels).toEqual([
      'push',
    ]);
  });

  it('refuses to remove push for a locked hos_* type', () => {
    const locked = row({ alertType: 'hos_warning', channels: ['push'] });
    expect(toggleChannel(locked, 'push', false).channels).toEqual(['push']);
  });

  it('allows removing push for a non-locked type', () => {
    const unlocked = row({ alertType: 'chat_message', channels: ['push'] });
    expect(toggleChannel(unlocked, 'push', false).channels).toEqual([]);
  });

  it('does not duplicate an already-present channel', () => {
    expect(toggleChannel(row({ channels: ['push'] }), 'push', true).channels).toEqual(['push']);
  });
});

describe('buildNotificationSettingsPayload', () => {
  it('includes only changed rows', () => {
    const original = [
      row({ alertType: 'chat_message', channels: ['push'] }),
      row({ alertType: 'hos_warning', channels: ['push'] }),
    ];
    const draft = [
      row({ alertType: 'chat_message', channels: ['push', 'email'] }),
      row({ alertType: 'hos_warning', channels: ['push'] }),
    ];
    const payload = buildNotificationSettingsPayload(original, draft);
    expect(payload).toHaveLength(1);
    expect(payload.at(0)).toMatchObject({
      alert_type: 'chat_message',
      channels: ['push', 'email'],
    });
  });

  it('returns an empty array when nothing changed', () => {
    const rows = [row({ alertType: 'chat_message' })];
    expect(buildNotificationSettingsPayload(rows, rows)).toEqual([]);
  });

  it('force-includes push for locked types even if the draft tried to drop it', () => {
    const original = [row({ alertType: 'hos_violation', channels: ['push'] })];
    const draft = [row({ alertType: 'hos_violation', channels: ['push'], recipientRoles: ['r1'] })];
    const payload = buildNotificationSettingsPayload(original, draft);
    expect(payload.at(0)?.channels).toContain('push');
  });
});
