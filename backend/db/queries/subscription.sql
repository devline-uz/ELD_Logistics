-- Obuna holati — `RequireWritableSubscription` middleware uchun (TZ B§15).
-- Faqat o'qish: obunani Super Admin paneli o'zgartiradi.

-- name: GetCompanySubscription :one
SELECT subscription_status, subscription_end_at
FROM companies
WHERE id = $1 AND deleted_at IS NULL;
