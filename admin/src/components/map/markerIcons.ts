/**
 * Duty-status marker ikonkalari — canvas orqali generatsiya qilinib
 * `map.addImage()` bilan ro'yxatdan o'tkaziladi (`fe-map` skill):
 * `DR` — strelka (`heading_deg` bo'yicha aylantiriladi), `ON` — nuqta,
 * `OFF` — pauza belgisi, `SB` — halqa.
 *
 * Sprite fayl/tashqi asset ishlatilmaydi — provayderga bog'liqlik yo'q (F164).
 */
import type { Map as MapLibreMap } from 'maplibre-gl';

export type DutyStatus = 'OFF' | 'SB' | 'DR' | 'ON';

const ICON_SIZE = 32;

/** Tailwind config'dagi asosiy ranglar bilan mos (fe-design-system). */
const DUTY_COLORS: Record<DutyStatus, string> = {
  OFF: '#8A94A6',
  SB: '#2F6FED',
  DR: '#1AA05D',
  ON: '#F6BA47',
};

function makeCanvas(): { canvas: HTMLCanvasElement; ctx: CanvasRenderingContext2D } {
  const canvas = document.createElement('canvas');
  canvas.width = ICON_SIZE;
  canvas.height = ICON_SIZE;
  const ctx = canvas.getContext('2d');
  if (!ctx) throw new Error('2D canvas context unavailable');
  return { canvas, ctx };
}

function drawArrow(ctx: CanvasRenderingContext2D, color: string): void {
  const c = ICON_SIZE / 2;
  ctx.fillStyle = color;
  ctx.beginPath();
  ctx.moveTo(c, 4);
  ctx.lineTo(c + 9, c + 10);
  ctx.lineTo(c, c + 4);
  ctx.lineTo(c - 9, c + 10);
  ctx.closePath();
  ctx.fill();
}

function drawDot(ctx: CanvasRenderingContext2D, color: string): void {
  const c = ICON_SIZE / 2;
  ctx.fillStyle = color;
  ctx.beginPath();
  ctx.arc(c, c, 9, 0, Math.PI * 2);
  ctx.fill();
}

function drawPause(ctx: CanvasRenderingContext2D, color: string): void {
  const c = ICON_SIZE / 2;
  ctx.fillStyle = color;
  ctx.fillRect(c - 8, c - 9, 6, 18);
  ctx.fillRect(c + 2, c - 9, 6, 18);
}

function drawRing(ctx: CanvasRenderingContext2D, color: string): void {
  const c = ICON_SIZE / 2;
  ctx.strokeStyle = color;
  ctx.lineWidth = 3;
  ctx.beginPath();
  ctx.arc(c, c, 8, 0, Math.PI * 2);
  ctx.stroke();
}

/** Har `DutyStatus` uchun ImageData generatsiya qiladi. */
function buildIcon(status: DutyStatus): ImageData {
  const { canvas, ctx } = makeCanvas();
  const color = DUTY_COLORS[status];
  if (status === 'DR') drawArrow(ctx, color);
  else if (status === 'ON') drawDot(ctx, color);
  else if (status === 'OFF') drawPause(ctx, color);
  else drawRing(ctx, color);
  return ctx.getImageData(0, 0, ICON_SIZE, ICON_SIZE);
}

export function dutyStatusIconName(status: string): string {
  return `unit-duty-${status.toLowerCase()}`;
}

/** Barcha 4 ikonkani xarita instansiyasiga ro'yxatdan o'tkazadi (idempotent). */
export function registerDutyStatusIcons(map: MapLibreMap): void {
  const statuses: DutyStatus[] = ['OFF', 'SB', 'DR', 'ON'];
  for (const status of statuses) {
    const name = dutyStatusIconName(status);
    if (map.hasImage(name)) continue;
    map.addImage(name, buildIcon(status), { pixelRatio: 2 });
  }
}
