import type { RouteObject } from 'react-router-dom';

import { fleetARoutes } from '@/app/router/fleet-a.routes';
import { fleetBRoutes } from '@/app/router/fleet-b.routes';

/**
 * Fleet Management — `fleet-a.routes.tsx` (Units/ELD Devices/Trailers/
 * Shipping Documents) va `fleet-b.routes.tsx` (Drivers/Users/Roles)
 * birlashtirilgan yagona marshrutlar ro'yxati (W11 — asosiy sessiya ishi).
 */
export const fleetRoutes: RouteObject[] = [...fleetARoutes, ...fleetBRoutes];
