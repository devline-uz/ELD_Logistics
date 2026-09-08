import { describe, expect, it } from 'vitest';

import { ALERT_TYPES, alertSeverity, shouldToastForAlertType } from './alertTypes';

describe('ALERT_TYPES', () => {
  it('lists all 16 backend alert_type values', () => {
    expect(ALERT_TYPES).toHaveLength(16);
    expect(new Set(ALERT_TYPES).size).toBe(16);
  });
});

describe('alertSeverity', () => {
  it('classifies violation-family and malfunction types as error', () => {
    expect(alertSeverity('hos_violation')).toBe('error');
    expect(alertSeverity('dvir_critical')).toBe('error');
    expect(alertSeverity('eld_malfunction')).toBe('error');
    expect(alertSeverity('eld_disconnected')).toBe('error');
  });

  it('classifies warning-family types as warning', () => {
    expect(alertSeverity('hos_warning')).toBe('warning');
    expect(alertSeverity('dvir_defects')).toBe('warning');
    expect(alertSeverity('maintenance_overdue')).toBe('warning');
    expect(alertSeverity('maintenance_upcoming')).toBe('warning');
  });

  it('falls back to neutral for informational types and missing values', () => {
    expect(alertSeverity('chat_message')).toBe('neutral');
    expect(alertSeverity(undefined)).toBe('neutral');
    expect(alertSeverity(null)).toBe('neutral');
  });
});

describe('shouldToastForAlertType (F143)', () => {
  it('toasts for *_violation, dvir_critical and eld_malfunction', () => {
    expect(shouldToastForAlertType('hos_violation')).toBe(true);
    expect(shouldToastForAlertType('dvir_critical')).toBe(true);
    expect(shouldToastForAlertType('eld_malfunction')).toBe(true);
  });

  it('does not toast for other alert types', () => {
    expect(shouldToastForAlertType('hos_warning')).toBe(false);
    expect(shouldToastForAlertType('chat_message')).toBe(false);
    expect(shouldToastForAlertType('eld_disconnected')).toBe(false);
    expect(shouldToastForAlertType(undefined)).toBe(false);
  });
});
