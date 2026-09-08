/**
 * Birlik konvertatsiyasi — 5.8 chiqish mezoni.
 *
 * Asosiy talab: konvertatsiya **ikki tomonlama to'g'ri** — kiritilgan qiymat
 * saqlanib, forma qayta ochilganda o'zgarmaydi.
 */
import { describe, expect, it } from 'vitest';

import {
  choiceOf,
  distanceUnitFor,
  formatIntervalDistance,
  intervalUnitLabel,
  isDistanceUnit,
  toApiInterval,
  toUserIntervalValue,
  unitSystemOf,
} from './intervalUnits';

describe('intervalUnits — birlik aniqlash', () => {
  it('masofa birliklarini ajratadi', () => {
    expect(isDistanceUnit('km')).toBe(true);
    expect(isDistanceUnit('mi')).toBe(true);
    expect(isDistanceUnit('days')).toBe(false);
    expect(isDistanceUnit('engine_hours')).toBe(false);
    expect(isDistanceUnit(undefined)).toBe(false);
  });

  it('saqlangan birlikni tizimga bog‘laydi', () => {
    expect(unitSystemOf('km')).toBe('metric');
    expect(unitSystemOf('mi')).toBe('imperial');
    expect(distanceUnitFor('metric')).toBe('km');
    expect(distanceUnitFor('imperial')).toBe('mi');
  });

  it('forma tanlovini saqlangan birlikdan tiklaydi', () => {
    expect(choiceOf('km')).toBe('distance');
    expect(choiceOf('mi')).toBe('distance');
    expect(choiceOf('days')).toBe('days');
    expect(choiceOf('engine_hours')).toBe('engine_hours');
    expect(choiceOf(undefined)).toBe('days');
  });

  it('yorliq har doim foydalanuvchi tizimiga mos', () => {
    expect(intervalUnitLabel('distance', 'metric')).toBe('km');
    expect(intervalUnitLabel('distance', 'imperial')).toBe('mi');
    expect(intervalUnitLabel('days', 'imperial')).toBe('days');
    expect(intervalUnitLabel('engine_hours', 'metric')).toBe('engine_hours');
  });
});

describe('intervalUnits — ikki tomonlama konvertatsiya (5.8)', () => {
  it('bir xil tizimda qiymat aynan saqlanadi (metric)', () => {
    const entered = 25000;
    const api = toApiInterval(entered, 'distance', 'metric');
    expect(api).toEqual({ interval_value: 25000, interval_unit: 'km' });

    // Formani qayta ochish — qiymat o'zgarmasligi shart.
    expect(toUserIntervalValue(api.interval_value, api.interval_unit, 'metric')).toBe(entered);
  });

  it('bir xil tizimda qiymat aynan saqlanadi (imperial)', () => {
    const entered = 15000;
    const api = toApiInterval(entered, 'distance', 'imperial');
    expect(api).toEqual({ interval_value: 15000, interval_unit: 'mi' });

    expect(toUserIntervalValue(api.interval_value, api.interval_unit, 'imperial')).toBe(entered);
  });

  it('kasrli qiymat ham aylanma yo‘ldan o‘zgarmasdan qaytadi', () => {
    for (const entered of [0.5, 1.1, 123.4, 99999.9]) {
      const api = toApiInterval(entered, 'distance', 'imperial');
      expect(toUserIntervalValue(api.interval_value, api.interval_unit, 'imperial')).toBe(entered);

      const metricApi = toApiInterval(entered, 'distance', 'metric');
      expect(toUserIntervalValue(metricApi.interval_value, metricApi.interval_unit, 'metric')).toBe(
        entered,
      );
    }
  });

  it('boshqa tizimda saqlangan qiymatni to‘g‘ri o‘giradi', () => {
    // 25 000 km → 15 534.28 mi
    expect(toUserIntervalValue(25000, 'km', 'imperial')).toBeCloseTo(15534.279, 2);
    // 15 000 mi → 24 140.16 km
    expect(toUserIntervalValue(15000, 'mi', 'metric')).toBeCloseTo(24140.16, 2);
  });

  it('ikki marta o‘girish boshlang‘ich qiymatni tiklaydi', () => {
    const kmValue = 25000;
    const asMiles = toUserIntervalValue(kmValue, 'km', 'imperial');
    expect(asMiles).not.toBeNull();
    const backToKm = toUserIntervalValue(asMiles, 'mi', 'metric');
    expect(backToKm).toBeCloseTo(kmValue, 1);
  });

  it('days va engine_hours konvertatsiya qilinmaydi', () => {
    expect(toUserIntervalValue(30, 'days', 'imperial')).toBe(30);
    expect(toUserIntervalValue(250, 'engine_hours', 'metric')).toBe(250);
    expect(toApiInterval(30, 'days', 'imperial')).toEqual({
      interval_value: 30,
      interval_unit: 'days',
    });
  });

  it('chegaraviy holatlar: null, undefined, NaN, 0, manfiy', () => {
    expect(toUserIntervalValue(null, 'km', 'metric')).toBeNull();
    expect(toUserIntervalValue(undefined, 'km', 'metric')).toBeNull();
    expect(toUserIntervalValue(Number.NaN, 'km', 'metric')).toBeNull();
    expect(toUserIntervalValue(0, 'km', 'imperial')).toBe(0);
    // `remaining` manfiy bo'lishi mumkin (Overdue) — konvertatsiya ishlashi shart.
    expect(toUserIntervalValue(-1000, 'km', 'metric')).toBe(-1000);
    expect(toUserIntervalValue(-1609.344, 'mi', 'metric')).toBeCloseTo(-2589.988, 2);
  });
});

describe('formatIntervalDistance — yorliq bilan ko‘rsatish', () => {
  it('yorliq har doim qo‘shiladi', () => {
    expect(formatIntervalDistance(25000, 'km', 'metric')).toBe('25,000.0 km');
    expect(formatIntervalDistance(15000, 'mi', 'imperial')).toBe('15,000.0 mi');
  });

  it('boshqa tizimda saqlangan qiymatni foydalanuvchi birligida ko‘rsatadi', () => {
    expect(formatIntervalDistance(25000, 'km', 'imperial')).toBe('15,534.3 mi');
  });

  it('yaroqsiz qiymat uchun N/A', () => {
    expect(formatIntervalDistance(null, 'km', 'metric')).toBe('N/A');
    expect(formatIntervalDistance(undefined, 'mi', 'imperial')).toBe('N/A');
    expect(formatIntervalDistance(Number.NaN, 'km', 'metric')).toBe('N/A');
  });
});
