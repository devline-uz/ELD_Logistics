import type { ComponentType } from 'react';
import type { RouteObject } from 'react-router-dom';

import { RouteGuard } from '@/app/RouteGuard';
import type { Permission } from '@/lib/permissions';

export interface GuardedRouteOptions {
  permission?: Permission;
  anyOf?: readonly Permission[];
  allOf?: readonly Permission[];
}

/**
 * Lazy + `RouteGuard` bilan o'ralgan marshrut (0.20).
 *
 * `load()` bitta modul chunk'ini qaytaradi — React Router uni **bir marta**
 * yechadi va natijani keshlaydi, shuning uchun o'ralgan komponent identiteti
 * barqaror bo'ladi.
 */
export function guardedRoute(
  path: string,
  load: () => Promise<ComponentType>,
  options: GuardedRouteOptions = {},
): RouteObject {
  return {
    path,
    lazy: async () => {
      const Page = await load();
      const Guarded = () => (
        <RouteGuard {...options}>
          <Page />
        </RouteGuard>
      );
      Guarded.displayName = `Guarded(${path})`;
      return { Component: Guarded };
    },
  };
}

/** `index: true` marshrut uchun bir xil darvoza (Dashboard `/`). */
export function guardedIndexRoute(
  load: () => Promise<ComponentType>,
  options: GuardedRouteOptions = {},
): RouteObject {
  return {
    index: true,
    lazy: async () => {
      const Page = await load();
      const Guarded = () => (
        <RouteGuard {...options}>
          <Page />
        </RouteGuard>
      );
      Guarded.displayName = 'Guarded(index)';
      return { Component: Guarded };
    },
  };
}

/** Ruxsat talab qilmaydigan lazy marshrut (Settings — shaxsiy profil). */
export function lazyRoute(path: string, load: () => Promise<ComponentType>): RouteObject {
  return {
    path,
    lazy: async () => ({ Component: await load() }),
  };
}
