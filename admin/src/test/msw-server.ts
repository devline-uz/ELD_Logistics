/**
 * MSW test infratuzilmasi (fe-testing §MSW handler tashkil etish, F213).
 *
 * Har integratsiya testi o'z handler to'plamini import qiladi va shu
 * `server`ga `server.use(...)` bilan qo'shadi — global handler fayli
 * shishirilmaydi. Baza URL — `vite.config.ts` dagi `test.env.VITE_API_BASE_URL`
 * (`http://eldapi.test/api/v1`), haqiqiy backendga hech qachon so'rov ketmaydi.
 */
import { setupServer } from 'msw/node';

export const server = setupServer();

export const API_BASE_URL = 'http://eldapi.test/api/v1';
