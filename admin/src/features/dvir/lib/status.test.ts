/**
 * DVIR holat mashinasi (F106) — 6 holat, admin faqat bitta o'tishni boshlaydi
 * (`Record repair`); sertifikatlash — haydovchi endpointi.
 */
import { describe, expect, it } from 'vitest';

import {
  DVIR_FILTERABLE_STATUSES,
  DVIR_STATUSES,
  awaitsDriverCertification,
  canRecordRepair,
  isRepairBlockedByMissingSignature,
  canTransition,
  dvirStatusKey,
  dvirStatusTone,
} from './status';

describe('dvir status machine', () => {
  it('has exactly the six backend states', () => {
    expect(DVIR_STATUSES).toHaveLength(6);
    expect(DVIR_STATUSES).toContain('closed_no_certification');
  });

  it('hides the mobile-only draft state from the admin filter', () => {
    expect(DVIR_FILTERABLE_STATUSES).not.toContain('draft');
    expect(DVIR_FILTERABLE_STATUSES).toHaveLength(5);
  });

  it('allows repair only from submitted_defects_found with a mechanic signature (D30)', () => {
    const signature = 'c1/signature/2026/09/06/mech.png';
    expect(
      canRecordRepair({ status: 'submitted_defects_found', mechanic_signature_key: signature }),
    ).toBe(true);
    for (const status of DVIR_STATUSES.filter((s) => s !== 'submitted_defects_found')) {
      expect(canRecordRepair({ status, mechanic_signature_key: signature })).toBe(false);
    }
    expect(canRecordRepair({})).toBe(false);
  });

  it('blocks repair while the mechanic signature is still missing (D30)', () => {
    expect(canRecordRepair({ status: 'submitted_defects_found' })).toBe(false);
    expect(isRepairBlockedByMissingSignature({ status: 'submitted_defects_found' })).toBe(true);
    expect(
      isRepairBlockedByMissingSignature({
        status: 'submitted_defects_found',
        mechanic_signature_key: 'c1/signature/2026/09/06/mech.png',
      }),
    ).toBe(false);
    expect(isRepairBlockedByMissingSignature({ status: 'repaired' })).toBe(false);
  });

  it('marks only repaired as awaiting driver certification (admin never certifies)', () => {
    expect(awaitsDriverCertification('repaired')).toBe(true);
    for (const status of DVIR_STATUSES.filter((s) => s !== 'repaired')) {
      expect(awaitsDriverCertification(status)).toBe(false);
    }
    expect(awaitsDriverCertification(undefined)).toBe(false);
  });

  it('rejects transitions out of the terminal states', () => {
    expect(canTransition('certified', 'repaired')).toBe(false);
    expect(canTransition('closed_no_certification', 'certified')).toBe(false);
    expect(canTransition(undefined, 'repaired')).toBe(false);
  });

  it('maps every state to a tone and an i18n key', () => {
    for (const status of DVIR_STATUSES) {
      expect(dvirStatusTone(status)).toBeTruthy();
      expect(dvirStatusKey(status)).toBe(`enums.dvir_status.${status}`);
    }
    expect(dvirStatusTone(undefined)).toBe('neutral');
  });
});
