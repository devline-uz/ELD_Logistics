import { createContext, useContext } from 'react';

export type ToastVariant = 'success' | 'error' | 'warning' | 'info';

export interface Toast {
  id: string;
  variant: ToastVariant;
  /** Tayyor matn — chaqiruvchi `t()` bilan tarjima qilib beradi. */
  message: string;
}

export interface ToastApi {
  show: (toast: Omit<Toast, 'id'>) => string;
  dismiss: (id: string) => void;
}

const NOOP_TOAST_API: ToastApi = {
  show: () => '',
  dismiss: () => undefined,
};

export const ToastContext = createContext<ToastApi>(NOOP_TOAST_API);

export function useToast(): ToastApi {
  return useContext(ToastContext);
}
