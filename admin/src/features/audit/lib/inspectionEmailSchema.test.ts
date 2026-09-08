/**
 * `buildInspectionEmailSchema` — validatsiya testi (8.11).
 */
import { describe, expect, it } from 'vitest';

import { buildInspectionEmailSchema } from './inspectionEmailSchema';

const t = ((key: string) => key) as never;

describe('buildInspectionEmailSchema', () => {
  it('rejects an empty email', () => {
    const schema = buildInspectionEmailSchema(t);
    const result = schema.safeParse({ email: '', comment: '' });
    expect(result.success).toBe(false);
  });

  it('rejects an invalid email format', () => {
    const schema = buildInspectionEmailSchema(t);
    const result = schema.safeParse({ email: 'not-an-email', comment: '' });
    expect(result.success).toBe(false);
  });

  it('accepts a valid email with an optional comment', () => {
    const schema = buildInspectionEmailSchema(t);
    const result = schema.safeParse({ email: 'inspector@dot.gov', comment: 'Roadside stop' });
    expect(result.success).toBe(true);
  });

  it('rejects a comment longer than 500 characters', () => {
    const schema = buildInspectionEmailSchema(t);
    const result = schema.safeParse({ email: 'inspector@dot.gov', comment: 'a'.repeat(501) });
    expect(result.success).toBe(false);
  });
});
