import { useEffect, useRef, useState } from 'react';

/**
 * `429` javobidagi `Retry-After` uchun sekundlik hisoblagich (fe-api §6).
 * Tugma shu vaqt davomida `disabled` bo'lib qoladi, foydalanuvchi qachon
 * qayta urinishi mumkinligini aniq ko'radi.
 */
export function useRetryAfter(): {
  secondsLeft: number;
  start: (seconds: number) => void;
} {
  const [secondsLeft, setSecondsLeft] = useState(0);
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);

  useEffect(
    () => () => {
      if (intervalRef.current) clearInterval(intervalRef.current);
    },
    [],
  );

  function start(seconds: number): void {
    if (intervalRef.current) clearInterval(intervalRef.current);
    setSecondsLeft(Math.max(0, Math.ceil(seconds)));

    intervalRef.current = setInterval(() => {
      setSecondsLeft((current) => {
        if (current <= 1) {
          if (intervalRef.current) clearInterval(intervalRef.current);
          return 0;
        }
        return current - 1;
      });
    }, 1000);
  }

  return { secondsLeft, start };
}
