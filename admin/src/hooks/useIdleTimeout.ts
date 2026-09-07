import { useCallback, useEffect, useRef, useState } from 'react';

/** 30 daqiqa harakatsizlik (0.22). */
export const IDLE_TIMEOUT_MS = 30 * 60 * 1000;
/** Chiqarishdan 60 s oldin ogohlantirish oynasi. */
export const IDLE_WARNING_MS = 60 * 1000;

const ACTIVITY_EVENTS = [
  'mousedown',
  'keydown',
  'wheel',
  'touchstart',
  'visibilitychange',
] as const;

export interface UseIdleTimeoutOptions {
  /** Umumiy harakatsizlik chegarasi. */
  timeoutMs?: number;
  /** Chegaradan qancha oldin ogohlantirish ko'rsatiladi. */
  warningMs?: number;
  /** Chegara o'tganda chaqiriladi (logout). */
  onTimeout: () => void;
  /** Kuzatuv yoqilganmi (login qilinmagan holatda `false`). */
  enabled?: boolean;
}

export interface IdleTimeoutState {
  /** Ogohlantirish oynasi ochiqmi. */
  isWarning: boolean;
  /** Chiqarishgacha qolgan sekundlar (ogohlantirish davomida). */
  secondsLeft: number;
  /** «Stay signed in» — taymerni noldan boshlaydi. */
  reset: () => void;
}

/**
 * Harakatsizlik taymeri. Foydalanuvchi faolligi (`mousedown`, `keydown`, …)
 * taymerni tiklaydi; `timeout - warning` da ogohlantirish, `timeout` da
 * `onTimeout()` chaqiriladi.
 */
export function useIdleTimeout({
  timeoutMs = IDLE_TIMEOUT_MS,
  warningMs = IDLE_WARNING_MS,
  onTimeout,
  enabled = true,
}: UseIdleTimeoutOptions): IdleTimeoutState {
  const [isWarning, setIsWarning] = useState(false);
  const [secondsLeft, setSecondsLeft] = useState(Math.ceil(warningMs / 1000));
  const deadline = useRef(Date.now() + timeoutMs);
  const onTimeoutRef = useRef(onTimeout);
  onTimeoutRef.current = onTimeout;
  const isWarningRef = useRef(isWarning);
  isWarningRef.current = isWarning;

  const reset = useCallback(() => {
    deadline.current = Date.now() + timeoutMs;
    setIsWarning(false);
    setSecondsLeft(Math.ceil(warningMs / 1000));
  }, [timeoutMs, warningMs]);

  useEffect(() => {
    if (!enabled) {
      return;
    }
    reset();

    const onActivity = () => {
      // Ogohlantirish ochilganda faqat dialogdagi tugma taymerni tiklaydi —
      // aks holda sichqoncha tebranishi chiqarishni cheksiz kechiktiradi.
      if (!isWarningRef.current) {
        deadline.current = Date.now() + timeoutMs;
      }
    };

    for (const event of ACTIVITY_EVENTS) {
      window.addEventListener(event, onActivity, { passive: true });
    }

    const interval = setInterval(() => {
      const remaining = deadline.current - Date.now();
      if (remaining <= 0) {
        onTimeoutRef.current();
        return;
      }
      if (remaining <= warningMs) {
        setIsWarning(true);
        setSecondsLeft(Math.ceil(remaining / 1000));
      }
    }, 1000);

    return () => {
      clearInterval(interval);
      for (const event of ACTIVITY_EVENTS) {
        window.removeEventListener(event, onActivity);
      }
    };
  }, [enabled, reset, timeoutMs, warningMs]);

  return { isWarning, secondsLeft, reset };
}
