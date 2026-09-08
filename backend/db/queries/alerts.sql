-- Fon vazifalari uchun query'lar (TZ A§19 cron alertlari). Bularning hammasi
-- platforma yoki tenant darajasida `internal/jobs` dan chaqiriladi.

-- Kompaniyalar va ularning TZ'lari — 20:00 Company TZ alerti uchun.
-- name: AlertsActiveCompanies :many
SELECT id, timezone, subscription_status, subscription_end_at
FROM companies
WHERE deleted_at IS NULL AND subscription_status <> 'readonly'
ORDER BY created_at
LIMIT $1;

-- Sertifikatlanmagan kunlik loglar egalari (kuniga 1 marta, 20:00 Company TZ).
-- name: AlertsUncertifiedLogDrivers :many
SELECT dl.driver_id, d.user_id, count(*)::bigint AS log_count, min(dl.log_date)::date AS oldest_log_date
FROM daily_logs dl
JOIN drivers d ON d.id = dl.driver_id AND d.deleted_at IS NULL AND d.status = 'active'
WHERE dl.company_id = $1
  AND dl.certification_status <> 'certified'
  AND dl.log_date <= $2::date
GROUP BY dl.driver_id, d.user_id
ORDER BY dl.driver_id
LIMIT $3;

-- 8 kundan beri biriktirilmagan haydash bloklari (unidentified_driving alerti).
-- name: AlertsStaleUnidentifiedCount :one
SELECT count(*)::bigint FROM unidentified_events
WHERE company_id = $1 AND status = 'pending' AND start_at < $2;

-- Obuna tugash sanasi aniq N kundan keyin bo'lgan kompaniyalar.
-- name: AlertsCompaniesExpiringOn :many
SELECT id, name, subscription_end_at
FROM companies
WHERE deleted_at IS NULL
  AND subscription_end_at IS NOT NULL
  AND (subscription_end_at AT TIME ZONE timezone)::date = ($1::date)
LIMIT $2;

-- Administrator rolidagi foydalanuvchilar (obuna alerti aynan ularga boradi).
-- name: AlertsCompanyAdministrators :many
SELECT u.id FROM users u
JOIN roles r ON r.id = u.role_id
WHERE u.company_id = $1 AND u.deleted_at IS NULL AND u.status = 'active'
  AND r.name = 'Administrator';
