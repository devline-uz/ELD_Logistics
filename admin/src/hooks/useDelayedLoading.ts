import { useEffect, useState } from 'react';

/**
 * Spinner/skeleton faqat `delayMs` (default 300ms) dan keyin ko'rinadi —
 * tezkor javoblarda miltillashning oldini oladi (fe-screens §6).
 */
export function useDelayedLoading(isLoading: boolean, delayMs = 300): boolean {
  const [showLoading, setShowLoading] = useState(false);

  useEffect(() => {
    if (!isLoading) {
      setShowLoading(false);
      return;
    }
    const timer = setTimeout(() => {
      setShowLoading(true);
    }, delayMs);
    return () => {
      clearTimeout(timer);
    };
  }, [isLoading, delayMs]);

  return showLoading;
}

export default useDelayedLoading;
