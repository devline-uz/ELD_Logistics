/**
 * Chop etish (`@media print`) stillari uchun sodda CSS-parse testi (Bosqich 6.9).
 *
 * DOM'da print media'ni simulyatsiya qilish imkoni cheklangan (jsdom `@media print`
 * ni bajarmaydi), shuning uchun `src/styles/index.css` ni PostCSS bilan parse qilib,
 * kerakli qoidalar mavjudligini tekshiramiz — real CSS o'zgarishini kuzatadi
 * (matn qidirish emas, chunki formatlash o'zgarsa test yolg'ondan sinishi mumkin).
 */
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

import postcss, { type AtRule, type Rule } from 'postcss';
import { describe, expect, it } from 'vitest';

const css = readFileSync(join(__dirname, 'index.css'), 'utf-8');
const root = postcss.parse(css);

function findPrintMedia(): AtRule | undefined {
  let printAtRule: AtRule | undefined;
  root.walkAtRules('media', (atRule) => {
    if (atRule.params.includes('print')) {
      printAtRule = atRule;
    }
  });
  return printAtRule;
}

/** `@media print` bloki ichidagi selektorlarni tekis ro'yxatga yig'adi. */
function collectSelectors(atRule: AtRule): string[] {
  const selectors: string[] = [];
  atRule.walkRules((rule) => {
    selectors.push(...rule.selector.split(',').map((s) => s.trim()));
  });
  return selectors;
}

describe('print styles (@media print)', () => {
  const printAtRule = findPrintMedia();

  it('index.css da @media print bloki mavjud', () => {
    expect(printAtRule).toBeDefined();
  });

  it('faqat [data-print-root] koʻrinadi, qolgani yashirin', () => {
    const selectors = collectSelectors(printAtRule!);
    expect(selectors).toContain('body *');
    expect(selectors).toContain('[data-print-root]');

    const bodyStarRule = (printAtRule!.nodes ?? []).find(
      (node): node is Rule => node.type === 'rule' && node.selector === 'body *',
    );
    expect(bodyStarRule?.toString()).toMatch(/visibility:\s*hidden/);
  });

  it('nav/header/sidebar va modal/toast chop etilmaydi', () => {
    const selectors = collectSelectors(printAtRule!);
    expect(selectors).toContain('header');
    expect(selectors).toContain('nav');
    expect(selectors).toContain('aside');
    expect(selectors).toContain("[role='dialog']");
    expect(selectors).toContain("[role='status']");
  });

  it('filtr paneli, tugmalar va paginatsiya yashirin, jadval sarlavha tugmasi qoladi', () => {
    const selectors = collectSelectors(printAtRule!);
    expect(selectors).toContain("[data-print-root] [role='tablist']");
    expect(selectors).toContain('[data-print-root] button:not(thead button)');
    expect(selectors).toContain('[data-print-root] input');
  });

  it('sticky ustun oddiy ustunga aylanadi, qatorlar sahifa ichida boʻlinmaydi', () => {
    const selectors = collectSelectors(printAtRule!);
    expect(selectors).toContain('[data-print-root] .sticky');
    expect(selectors).toContain('[data-print-root] .overflow-x-auto');

    const rowRule = (printAtRule!.nodes ?? []).find(
      (node): node is Rule => node.type === 'rule' && node.selector === '[data-print-root] tr',
    );
    expect(rowRule?.toString()).toMatch(/break-inside:\s*avoid/);
  });

  it('holat ranglari (badge/KPI) uchun print-color-adjust: exact beriladi', () => {
    const printColorAdjustRule = (printAtRule!.nodes ?? []).find(
      (node): node is Rule =>
        node.type === 'rule' && node.toString().includes('print-color-adjust: exact'),
    );
    expect(printColorAdjustRule).toBeDefined();
    expect(printColorAdjustRule?.selector).toContain("[class*='bg-success']");
  });
});
