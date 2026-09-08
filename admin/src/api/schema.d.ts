/**
 * @generated
 *
 * GENERATSIYA NATIJASI — QO'LDA TEGILMAYDI.
 * Yangilash: `DOCS_TOKEN=<token> npm run api`
 *
 * Oqim:
 *   openapi/swagger.json   ← backend (Swagger 2.0, swaggo)
 *   openapi/openapi3.json  ← swagger2openapi konvertatsiyasi (OpenAPI 3.0)
 *   src/api/schema.d.ts    ← openapi-typescript (shu fayl)
 *
 * Domen tiplari komponentlarda `src/api/types.ts` alias'lari orqali ishlatiladi.
 */

export interface paths {
    "/app/config": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Client bootstrap configuration
         * @description Versioning gate for the mobile client: `min_supported_version`, `latest_version`, `force_update` and the deployment feature flags. Public, but rate limited to 60 requests per minute per address and served from a 45 second cache.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.AppConfigEnvelope"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/audit-log": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List audit log entries
         * @description TZ A§17 — the single audit trail; the four journals of the UI are filtered views of this endpoint. Newest first by default. `old_value` and `new_value` are masked: a password hash, session token, encrypted column or driver licence number is returned as `[REDACTED]` and `masked` is true. The table is append-only, so there is no create, update or delete route.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                    /** @description Timestamp order */
                    order?: "asc" | "desc";
                    /**
                     * @description Audited table name
                     * @example support_tickets
                     */
                    table?: string;
                    /** @description Audited row id (uuid) */
                    record_id?: string;
                    /** @description Acting user id (uuid), matches audit_log.edited_by */
                    user?: string;
                    /**
                     * @description Audited action
                     * @example update
                     */
                    action?: string;
                    /** @description Timestamp at or after (RFC3339) */
                    from?: string;
                    /** @description Timestamp before (RFC3339) */
                    to?: string;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auditlog_dto.EntryListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auditlog_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auditlog_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auditlog_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auditlog_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/audit-log/tables": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List audited table names
         * @description Distinct `audit_log.table_name` values of the company, for the filter dropdown of the audit journal screen.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auditlog_dto.TableListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auditlog_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auditlog_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/auth/2fa/setup": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Start two factor enrolment
         * @description Q3.4 — mandatory for Super Admin and Administrator. The shared secret is stored AES-256-GCM encrypted and is only enabled once POST /auth/2fa/verify succeeds.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.TOTPSetupEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description TOTP_ALREADY_ENABLED */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/auth/2fa/verify": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Confirm a two factor code
         * @description Q3.4 — confirming an enrolment returns the ten single use recovery codes exactly once and upgrades a limited token into a full session.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            /** @description TOTP or recovery code */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.TOTPVerifyRequest"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.TOTPVerifiedEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED / TOTP_INVALID */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description TOTP_SETUP_REQUIRED */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/auth/invitation/accept": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Accept an invitation
         * @description Q16 — the link is valid for 72 hours and only its SHA-256 hash is stored. Setting the password revokes every existing session of the account.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            /** @description Invitation token and new password */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.InvitationAcceptRequest"];
                };
            };
            responses: {
                /** @description No Content */
                204: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
                /** @description INVITATION_INVALID / INVITATION_EXPIRED / INVITATION_USED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description ACCOUNT_INACTIVE */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR / PASSWORD_WEAK / PIN_INVALID */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/auth/login": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Sign in
         * @description Q20 — one session per device_type: signing in on the same device type revokes the previous session and answers `replaced_session: true`. Super Admin and Administrator accounts without 2FA receive a limited token and `requires_totp_setup: true`.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            /** @description Credentials */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.LoginRequest"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.LoginEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description INVALID_CREDENTIALS / TOTP_REQUIRED / TOTP_INVALID */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description ACCOUNT_INACTIVE / SUBSCRIPTION_EXPIRED */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED / LOCKED_OUT */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/auth/logout": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Sign out or pause the session
         * @description Q3.1 — `pause: true` is Leave Truck: the session becomes `paused` and is resumed with POST /auth/pin/verify.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            /** @description Logout options */
            requestBody?: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.LogoutRequest"];
                };
            };
            responses: {
                /** @description No Content */
                204: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/auth/password/forgot": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Request a password reset link
         * @description Q16 — always answers 202 so the endpoint cannot enumerate accounts. A new link invalidates the previous one.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            /** @description Username or email */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.PasswordForgotRequest"];
                };
            };
            responses: {
                /** @description Accepted */
                202: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.MessageEnvelope"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/auth/password/reset": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Reset the password
         * @description Q16 — the token works once. A successful reset revokes every session of the account.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            /** @description Reset token and new password */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.PasswordResetRequest"];
                };
            };
            responses: {
                /** @description No Content */
                204: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
                /** @description INVITATION_INVALID / INVITATION_EXPIRED / INVITATION_USED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description ACCOUNT_INACTIVE */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR / PASSWORD_WEAK */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/auth/pin/verify": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Verify the driver PIN
         * @description Q16 — Switch driver / Return to truck. `return_to_truck` resumes the paused session. Five consecutive failures lock the PIN for 15 minutes.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            /** @description PIN payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.PINVerifyRequest"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.PINVerifiedEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED / PIN_INVALID */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description PIN_NOT_SET */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description PIN_LOCKED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/auth/refresh": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Rotate the refresh token
         * @description Q3.1 — every refresh returns a new opaque token and invalidates the old one. Replaying a rotated token revokes the whole session and is audited as `token_reuse`.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            /** @description Refresh token */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.RefreshRequest"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.TokensEnvelope"];
                    };
                };
                /** @description TOKEN_INVALID / TOKEN_REUSED / TOKEN_REVOKED / SESSION_EXPIRED / PIN_REQUIRED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description ACCOUNT_INACTIVE */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/auth/sessions": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List my sessions
         * @description Q20 — the caller's own non revoked sessions, one per device type. Addresses are truncated.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.SessionListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/auth/sessions/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        post?: never;
        /**
         * Revoke one of my sessions
         * @description Q20 — a session belonging to another user answers 404, never 403, so session ids cannot be probed.
         */
        delete: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Session id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description No Content */
                204: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
            };
        };
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/chat/messages/{id}/read": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Acknowledge a chat message
         * @description TZ §15.4 — moves the message to `read`. Only the other side may acknowledge a message: acknowledging your own answers 200 with `updated: 0`. A message of another company answers 404.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Message id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ReadResultEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/chat/threads": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List chat threads
         * @description TZ §15.4 — the office side receives one thread per driver, newest activity first; drivers that never exchanged a message are included so a conversation can be started. A self scoped principal (driver) always receives exactly one thread, its own "Dispatch" conversation, whatever the query says. A branch scoped principal only sees the drivers of its branch.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                    /** @description Only threads that already hold a message */
                    with_messages?: boolean;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ThreadListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/chat/threads/{driver_id}/messages": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Read a chat thread
         * @description TZ §15.4 — cursor pagination, newest message first. Pass `before` (the `meta.next_before` of the previous page) to walk backwards; `meta.has_more` reports whether older messages exist. A driver may only read its own thread; another driver's id answers 404, never 403.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Cursor: return messages sent strictly before this instant */
                    before?: string;
                    /** @description Page size (max 200) */
                    limit?: number;
                };
                header?: never;
                path: {
                    /** @description Driver id */
                    driver_id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.MessageListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        /**
         * Send a chat message
         * @description TZ §15.4 — text (max 2000 characters), an image or PDF referenced by the `file_key` of POST /files/presign (max 10 MB, enforced at presign time), or a shared location. While the driver is in DR the driver side is blocked and answers 409 `DRIVING_MODE_BLOCKED` (driver distraction policy); the office may still write, and the app shows the message once the driver leaves DR. Delivery is WebSocket `chat` plus a push when the recipient is not connected.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Driver id */
                    driver_id: string;
                };
                cookie?: never;
            };
            /** @description Message payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.MessageCreate"];
                };
            };
            responses: {
                /** @description Created */
                201: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.MessageEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ErrorResponse"];
                    };
                };
                /** @description DRIVING_MODE_BLOCKED */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR / MESSAGE_TOO_LONG */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/companies": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List companies
         * @description TZ A§15 — the platform tenant list. Super Admin only: a company scoped principal receives 403.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Page number */
                    page?: number;
                    /** @description Page size */
                    per_page?: number;
                    /** @description Name contains */
                    search?: string;
                    /** @description Subscription status */
                    status?: "trial" | "active" | "grace" | "readonly";
                    /** @description Region profile */
                    region?: "PK" | "UZ" | "US" | "other";
                    /** @description Sort field */
                    sort?: "name" | "created_at" | "subscription_end_at";
                    /** @description Sort direction */
                    order?: "asc" | "desc";
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.AdminCompanyListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        /**
         * Create a company
         * @description TZ A§15 — provisions the tenant in one transaction: the company row, the FMCSA 70/8 default `hos_policy_versions` entry, a copy of the system roles with their permissions, the A§19 notification defaults, the Administrator account in `invited` state and its 72 h invitation. The invitation token is delivered out of band and never returned.
         */
        post: {
            parameters: {
                query?: never;
                header?: {
                    /** @description Repeat safe key */
                    "Idempotency-Key"?: string;
                };
                path?: never;
                cookie?: never;
            };
            /** @description Company payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.CompanyCreate"];
                };
            };
            responses: {
                /** @description Created */
                201: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.CompanyCreatedEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION / IDEMPOTENCY_CONFLICT */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/companies/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        /**
         * Update a company
         * @description Partial update from the platform console. An unknown or soft deleted company answers 404.
         */
        patch: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Company id */
                    id: string;
                };
                cookie?: never;
            };
            /** @description Company patch */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.CompanyUpdate"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.AdminCompanyEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.ErrorResponse"];
                    };
                };
            };
        };
        trace?: never;
    };
    "/companies/{id}/subscription": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        /**
         * Update a company subscription
         * @description TZ A§15 — MVP billing is manual: the platform administrator extends `subscription_end_at` once the invoice is settled. `grace` covers the 7 days after the period ends, `readonly` freezes the admin panel while the driver app keeps recording HOS.
         */
        patch: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Company id */
                    id: string;
                };
                cookie?: never;
            };
            /** @description Subscription patch */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.SubscriptionUpdate"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.AdminCompanyEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.ErrorResponse"];
                    };
                };
            };
        };
        trace?: never;
    };
    "/company": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Get the company profile
         * @description TZ A§1 — the tenant profile plus the region profile (region, unit_system, regulation_profile) and the company level settings document.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.CompanyEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        /**
         * Update the company profile
         * @description Q0.1/Q0.2 — region, unit_system and regulation_profile drive the labels and the unit conversion in every client. Omitted fields are left unchanged; `settings` replaces the whole settings document.
         */
        patch: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            /** @description Company patch */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.CompanyUpdate"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.CompanyEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
            };
        };
        trace?: never;
    };
    "/company/branches": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List branches
         * @description Company locations used as the Sub Admin scope target.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Page number */
                    page?: number;
                    /** @description Page size */
                    per_page?: number;
                    /** @description Name contains */
                    search?: string;
                    /** @description Sort field */
                    sort?: "name" | "created_at";
                    /** @description Sort direction */
                    order?: "asc" | "desc";
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.BranchListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        /** Create a branch */
        post: {
            parameters: {
                query?: never;
                header?: {
                    /** @description Repeat safe key */
                    "Idempotency-Key"?: string;
                };
                path?: never;
                cookie?: never;
            };
            /** @description Branch payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.BranchCreate"];
                };
            };
            responses: {
                /** @description Created */
                201: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.BranchEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION / IDEMPOTENCY_CONFLICT */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/company/branches/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        post?: never;
        /**
         * Delete a branch
         * @description Soft delete. A branch that still has assigned users answers 409 RESOURCE_IN_USE.
         */
        delete: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Branch id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description No Content */
                204: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description RESOURCE_IN_USE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
            };
        };
        options?: never;
        head?: never;
        /**
         * Update a branch
         * @description A branch of another tenant answers 404, never 403.
         */
        patch: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Branch id */
                    id: string;
                };
                cookie?: never;
            };
            /** @description Branch patch */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.BranchUpdate"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.BranchEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
            };
        };
        trace?: never;
    };
    "/company/history": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Company configuration history
         * @description The audit_log rows of the caller's company. The client IP is never returned.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Page number */
                    page?: number;
                    /** @description Page size */
                    per_page?: number;
                    /** @description Audited table name */
                    table?: string;
                    /** @description Audited action */
                    action?: string;
                    /** @description Audited record id */
                    record_id?: string;
                    /** @description Editor user id */
                    user?: string;
                    /** @description From timestamp (RFC3339) */
                    from?: string;
                    /** @description To timestamp, exclusive (RFC3339) */
                    to?: string;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.HistoryListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/company/hos-policy": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Get the effective HOS policy
         * @description Q10.1 — the hos_policy_versions row whose effective_from is the latest one not in the future. A company without a stored version falls back to the FMCSA 70/8 defaults.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.HosPolicyEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        /**
         * Publish a new HOS policy version
         * @description Q10.1 — a policy change is never retroactive: `effective_from` must not be in the past and days before it keep being evaluated with the previous version. Keys left out of `policy` inherit the currently effective value.
         */
        post: {
            parameters: {
                query?: never;
                header?: {
                    /** @description Repeat safe key */
                    "Idempotency-Key"?: string;
                };
                path?: never;
                cookie?: never;
            };
            /** @description Policy version */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.HosPolicyCreate"];
                };
            };
            responses: {
                /** @description Created */
                201: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.HosPolicyEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description IDEMPOTENCY_CONFLICT */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/company/notification-settings": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Get the notification settings
         * @description TZ A§19 — one entry per alert type with its delivery channels and the recipient role ids. Alert types the company never customised are returned with the defaults of the specification table.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.NotificationSettingsEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        /**
         * Update the notification settings
         * @description Q89 — only the listed alert types are written; the rest keep their configuration. `channels` replaces the previous list, an empty list mutes the alert for every channel.
         */
        patch: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            /** @description Alert configuration */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.NotificationSettingsUpdate"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.NotificationSettingsEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse"];
                    };
                };
            };
        };
        trace?: never;
    };
    "/daily-logs/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Daily log detail
         * @description Q13/Q16 — one log day with its events and its Log Form: unit(s), driver, co-driver, distance (from telemetry, never edited by hand), trailers, shipping documents and the signature. Superseded events stay in the answer with `superseded_by` so the ✎ edit history is visible (Q17.2). The stored violations of the day are included (Q57, server canonical).
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Daily log id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.DailyLogEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/daily-logs/{id}/certify": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Certify a daily log
         * @description Q26.1 — the driver signs the day: `signed_at`, the signature key, `signed_ip` and `signed_device_id` are stored, a `certification` event is written and the day's events become `locked` (only an approved edit request may move them afterwards). Q26: an administrator never certifies on the driver's behalf, so a caller that is not the owning driver is refused with 403. The signature is taken from `signature_key`, from `signature_id` (a stored signature of the same user) or from the driver's default; without any of them the day is `LOG_NOT_READY` (Q25).
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Daily log id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            /** @description Signature source */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.CertifyRequest"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.DailyLogEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description LOG_NOT_READY */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/daily-logs/{id}/events": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Driver log edit
         * @description Q17 — the driver's own correction. It is applied immediately with `origin=driver_edit`, `note` is mandatory and the original events are kept behind `superseded_by`. Q17.1 still applies: automatically recorded `DR` may not be shortened or turned into another status — the only permitted rewrite is the driver re-labelling it as Personal Conveyance or Yard Move; `intermediate`, `power_on/off` and `malfunction` events are never editable. A certified day falls back to `needs_recertify` (Q18).
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Daily log id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            /** @description Duty status interval */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.LogEventCreate"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.DailyLogEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description DR_IMMUTABLE / EVENT_IMMUTABLE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/daily-logs/{id}/pdf": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Daily log PDF
         * @description Q55 — the printable log: the 24 hour grid, the event list and the Log Form. The document is produced with headless Chrome; on a deployment without a Chromium binary the endpoint degrades to `text/html` with the same content instead of failing a roadside inspection.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Daily log id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/pdf": string;
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/pdf": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/pdf": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/pdf": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/pdf": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description INTERNAL_ERROR */
                500: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/pdf": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/dashboard/summary": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Dashboard summary
         * @description TZ A§20 — the KPI cards, the current duty status block and today's routes. Every window is cut on the company timezone: `active_units` counts the units that reported telemetry today, `drivers_on_duty` the drivers currently in ON or DR, `violations` the violations of the current ISO week (Monday–Sunday), `uncertified_logs` the logs uncertified for two days or more, and `unassigned_driving` the unidentified driving events still pending. `disconnected_eld` is the stored connectivity state; `malfunction_eld` is derived from the device diagnostics. A branch scoped principal sees only its own branch in the route block. The same payload is republished on the WebSocket `dashboard` channel, so a client either polls this endpoint every 60 seconds or subscribes.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dashboard_dto.SummaryEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dashboard_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dashboard_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dashboard_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/defect-types": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List defect types
         * @description Q27.1 — the inspection catalogue. Rows with `is_system=true` are the 61 FMCSA defaults shared by every tenant and are read only; a company adds its own entries alongside them. `is_critical` drives the Q27.2 out of service rule.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Catalogue section */
                    category?: "truck" | "trailer";
                    /** @description Only active / only inactive entries */
                    is_active?: boolean;
                    /** @description Only critical / only non critical entries */
                    is_critical?: boolean;
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.DefectTypeListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        /**
         * Create a defect type
         * @description Q27.1 — adds a company level catalogue entry. The name is unique per category inside the company; the shared defaults are untouched.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            /** @description Catalogue entry */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.DefectTypeCreate"];
                };
            };
            responses: {
                /** @description Created */
                201: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.DefectTypeEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/defect-types/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        /**
         * Update a defect type
         * @description Q27.1 — patches a company catalogue entry; nil fields are left untouched. The shared system defaults are read only and answer 409 `DEFECT_TYPE_SYSTEM_LOCKED`. Deactivating an entry (`is_active=false`) keeps historic reports intact but removes it from new inspections.
         */
        patch: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Defect type id */
                    id: string;
                };
                cookie?: never;
            };
            /** @description Patch payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.DefectTypeUpdate"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.DefectTypeEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description DEFECT_TYPE_SYSTEM_LOCKED / UNIQUE_VIOLATION */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
            };
        };
        trace?: never;
    };
    "/devices/push-token": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Register a push token
         * @description Q89 — registers the FCM (android/web) or APNs (ios) token of one installation, keyed by `device_id`, so a reinstall refreshes instead of duplicating. Registering a token that is already bound to another user retires the old registration: a handed over phone must not keep receiving the previous owner's alerts. The token itself is a credential and is never returned by any endpoint.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            /** @description Device registration */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.PushTokenCreate"];
                };
            };
            responses: {
                /** @description Created */
                201: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.PushTokenEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/drivers": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List drivers
         * @description Q1 — paginated Driver Management list. Filters: status, branch_id, fleet_manager_id, search. `include_inactive=false` hides deactivated drivers. Branch scoped callers only ever see their own branch. `license_no` is never returned in clear text.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                    /** @description Sort field */
                    sort?: "name" | "username" | "status" | "created_at";
                    /** @description Sort order */
                    order?: "asc" | "desc";
                    /** @description Name, username, email or phone fragment */
                    search?: string;
                    /** @description Driver status */
                    status?: "invited" | "active" | "inactive";
                    /** @description Branch id (uuid) */
                    branch_id?: string;
                    /** @description Fleet manager user id (uuid) */
                    fleet_manager_id?: string;
                    /** @description Include deactivated drivers */
                    include_inactive?: boolean;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.DriverListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        /**
         * Create a driver
         * @description Q18.1 — required: first_name, last_name, username (4-32 of [a-z0-9._]), license_no and at least one of email / phone (the invitation is delivered over it). **There is no password field**: a users row is created with the Driver role and status `invited`, and an invitation link is sent. `license_no` is stored AES-256-GCM encrypted and answered masked. Co-driver is optional.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            /** @description Driver payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.DriverCreate"];
                };
            };
            responses: {
                /** @description Created */
                201: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.DriverEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND (co-driver of another tenant) */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION / INVALID_STATE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/drivers/export": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Export drivers
         * @description Downloads the driver list as CSV (default) or XLSX. `license_no` is exported **masked**, never in clear text. Every download is recorded in `audit_log` (who exported what, TZ B§3.6).
         */
        get: {
            parameters: {
                query?: {
                    /** @description File format */
                    format?: "csv" | "xlsx";
                    /** @description Driver status */
                    status?: "invited" | "active" | "inactive";
                    /** @description Branch id (uuid) */
                    branch_id?: string;
                    /** @description Include deactivated drivers */
                    include_inactive?: boolean;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description CSV or XLSX file */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "text/csv": string;
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "text/csv": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "text/csv": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "text/csv": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/drivers/import": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Import drivers from CSV/XLSX
         * @description TZ §18.4 — multipart upload of `drivers_import_template` (first_name, last_name, username, phone, email, license_no, license_region, home_terminal). Validation is row by row and **all-or-nothing**: one critical error and nothing at all is written; the body then lists every `{row, field, message}` and the response status is 422. Every imported driver gets a users row (Driver role, status `invited`) and an invitation link; `license_no` is stored AES-256-GCM encrypted.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody: components["requestBodies"]["postDriversImport"];
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ImportResultEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION / INVALID_STATE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
                /** @description PAYLOAD_TOO_LARGE */
                413: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR — nothing was written */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ImportResultEnvelope"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/drivers/import-template": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Download the driver import template
         * @description TZ §18.4 — `drivers_import_template` with the exact column order the importer expects, plus one sample row.
         */
        get: {
            parameters: {
                query?: {
                    /** @description File format */
                    format?: "csv" | "xlsx";
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description CSV or XLSX file */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "text/csv": string;
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "text/csv": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "text/csv": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "text/csv": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/drivers/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Get a driver
         * @description Cross-tenant reads answer 404, never 403 (TZ B§3.5).
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Driver id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.DriverEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        /**
         * Delete a driver
         * @description Soft delete (`deleted_at`): the drivers row and its user account are archived and every session is revoked. Logs stay untouched.
         */
        delete: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Driver id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description No Content */
                204: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description RESOURCE_IN_USE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
            };
        };
        options?: never;
        head?: never;
        /**
         * Update a driver
         * @description Partial update; omitted fields stay unchanged. Changing `license_no` re-encrypts the column. `status`, `company_id` and the role can never be set here.
         */
        patch: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Driver id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            /** @description Fields to change */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.DriverUpdate"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.DriverEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
            };
        };
        trace?: never;
    };
    "/drivers/{id}/activate": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Activate a driver
         * @description Q1 — reversible transition back to `active`. A driver that never accepted the invitation keeps user status `invited`.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Driver id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: components["requestBodies"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.StatusChange"];
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.DriverEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/drivers/{id}/activities": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Driver activity feed
         * @description Every audited change of the driver and of its user account, its logins and its session state transitions, newest first. Sourced from `audit_log` and `sessions`.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                };
                header?: never;
                path: {
                    /** @description Driver id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ActivityListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/drivers/{id}/co-drivers": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List co-drivers
         * @description TZ §1.1 — the pair is stored once but shown on both sides: if B is a co-driver of A, A also appears in B's list.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Driver id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.CoDriverListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        /**
         * Link a co-driver
         * @description Q45 — creates one canonical `driver_pairs` row; the relation is symmetric. Re-linking a previously removed pair restores it instead of failing.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Driver id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            /** @description Co-driver to link */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.CoDriverCreate"];
                };
            };
            responses: {
                /** @description Created */
                201: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.CoDriverListEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
            };
        };
        /**
         * Unlink a co-driver (collection form)
         * @description TZ D§3 lists `DELETE /drivers/{id}/co-drivers`; the partner is named by the `co_driver_id` query parameter.
         */
        delete: {
            parameters: {
                query: {
                    /** @description Co-driver id (uuid) */
                    co_driver_id: string;
                };
                header?: never;
                path: {
                    /** @description Driver id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description No Content */
                204: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
            };
        };
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/drivers/{id}/co-drivers/{co_driver_id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        post?: never;
        /**
         * Unlink a co-driver
         * @description Soft deletes the `driver_pairs` row. The link disappears from both drivers.
         */
        delete: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Driver id (uuid) */
                    id: string;
                    /** @description Co-driver id (uuid) */
                    co_driver_id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description No Content */
                204: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
            };
        };
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/drivers/{id}/daily-logs": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Driver daily logs
         * @description Q19 — the certification window of one driver. The default window is the last 8 days (`certification_window_days`), cut in the home terminal timezone (Q10.2). `certification_status` is `uncertified`, `certified` or `needs_recertify`; `ready` is false while the day still misses its signature (Q25). A Driver (scope `self`) may only read its own logs; another company's driver id answers 404, never 403.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Window start, YYYY-MM-DD (default: 7 days before `to`) */
                    from?: string;
                    /** @description Window end, YYYY-MM-DD (default: today) */
                    to?: string;
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                };
                header?: never;
                path: {
                    /** @description Driver id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.DailyLogListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/drivers/{id}/deactivate": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Deactivate a driver
         * @description Q1 — an inactive driver cannot sign in (`403 ACCOUNT_INACTIVE`) and **every one of its sessions is revoked immediately**, so already issued access tokens stop working too.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Driver id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: components["requestBodies"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.StatusChange"];
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.DriverEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/drivers/{id}/duty-status-events": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List duty status events
         * @description TZ A§3 — the driver's duty status events inside [from, to). Superseded events (conflict rule 1) are hidden; the surviving row carries `superseded_by` on the loser instead. Times are UTC and the window may not exceed 62 days. A Driver (scope `self`) may only read its own events; another company's driver id answers 404, never 403.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Window start, RFC3339 (default: 8 days ago) */
                    from?: string;
                    /** @description Window end, RFC3339 (default: now) */
                    to?: string;
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                };
                header?: never;
                path: {
                    /** @description Driver id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_duty_dto.DutyStatusEventListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_duty_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_duty_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_duty_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_duty_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_duty_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/drivers/{id}/hos-summary": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Driver HOS summary
         * @description TZ A§4 — the BREAK/DRIVE/SHIFT/CYCLE counters, the four duty-line totals of the log day, the cycle recap (Q10.7) and the computed warnings/violations. The log day is the home terminal 00:00-24:00 window (Q10.2) and the policy is the `hos_policy_versions` row in force on that day, so a policy change never rewrites history (Q10.1). Violations are reported here but only persisted from stage 4 on — the server stays canonical. A Driver (scope `self`) may only read its own summary.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Log day, YYYY-MM-DD in the home terminal timezone (default: today) */
                    date?: string;
                };
                header?: never;
                path: {
                    /** @description Driver id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_duty_dto.HosSummaryEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_duty_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_duty_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_duty_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_duty_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_duty_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/drivers/{id}/license": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Reveal the driver licence number
         * @description TZ B§3.4 — `drivers.license_no` is stored AES-256-GCM encrypted. The list and the driver payload only ever carry `license_no_masked`; the clear value is served here and only to a caller holding `drivers.license.view`. Every call is answered from the encrypted column, never from a cache, and every reveal is written to `audit_log` as `license_reveal`.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Driver id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.DriverLicenseEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/drivers/{id}/reset-password": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Resend the driver invitation
         * @description Q18.1 — a driver password is only ever set through an invitation, so "reset password" reissues the link (72 h, delivered by email or SMS). The previous link is burned and every live session is revoked. The token is never returned over the API.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Driver id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ResetPasswordEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN / ACCOUNT_INACTIVE */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/dvir-reports": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List DVIR reports
         * @description TZ §7 — inspection reports of the tenant, newest first. `status` follows the §7.2 state machine and `kind` is the derived mobile label of §7.3 (`no_defects`, `defects_not_fixed`, `defects_uncertified`, `defects_fixed`). A self scoped principal (driver) only sees its own reports. Distances are metres; timestamps are ISO 8601 UTC.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Unit filter (uuid) */
                    unit_id?: string;
                    /** @description Driver filter (uuid) */
                    driver_id?: string;
                    /** @description Inspection type */
                    type?: "pre_trip" | "post_trip";
                    /** @description State machine status */
                    status?: "draft" | "submitted_no_defects" | "submitted_defects_found" | "repaired" | "certified" | "closed_no_certification";
                    /**
                     * @description Start of the window (RFC3339 UTC)
                     * @example 2026-09-01T00:00:00Z
                     */
                    from?: string;
                    /**
                     * @description End of the window, exclusive (RFC3339 UTC)
                     * @example 2026-09-08T00:00:00Z
                     */
                    to?: string;
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.DvirReportListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        /**
         * Submit a DVIR report
         * @description TZ §7.1 (mobile, driver only). Q31: an administrator never files a DVIR on a driver's behalf, so the caller must own a driver record — anyone else gets 403 `DVIR_ADMIN_CREATE_DENIED`. Q28: time, location, odometer and engine hours are captured server side from telemetry, so the body carries none of them. Q27.1: every defect references the `defect_types` catalogue and carries at most five photos. Q27.2: a defect flagged `is_critical` sets `units.out_of_service` and raises an immediate alert. The stored status is derived, not sent: no defects yields `submitted_no_defects`, any defect yields `submitted_defects_found` (the mobile `in_progress` state never reaches the server, Q30.2).
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            /** @description Inspection payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.DvirCreate"];
                };
            };
            responses: {
                /** @description Created */
                201: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.DvirReportEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description DVIR_ADMIN_CREATE_DENIED */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description DVIR_INVALID_TRANSITION */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR / DEFECT_TYPE_UNKNOWN */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/dvir-reports/pending-certification": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * DVIR reports pending certification
         * @description TZ §7.2 — the reports whose defects still wait for the driver's "Previous defects repaired?" signature. The mobile app calls this before a pre-trip DVIR of the same unit. Q30.1: after seven days without a follow-up report, or once the unit goes inactive, a background sweep closes the entry as `closed_no_certification` and it disappears from this list.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Unit filter (uuid) */
                    unit_id?: string;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.DvirReportListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/dvir-reports/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Get DVIR report
         * @description One inspection report with its defects, signatures and repair trail. Cross-tenant and out of scope ids answer 404, never 403.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description DVIR report id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.DvirReportEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/dvir-reports/{id}/certify": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Certify a repaired DVIR
         * @description TZ §7.2 — the driver answers "Previous defects repaired?" with a signature, moving `repaired` → `certified`. Q30.1: a different driver of the same tenant is accepted, so the endpoint only requires the caller to own a driver record. Once a critical defect report is certified the unit leaves `out_of_service`. Any other source status answers 409 `DVIR_INVALID_TRANSITION`.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description DVIR report id */
                    id: string;
                };
                cookie?: never;
            };
            /** @description Driver signature */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.DvirCertify"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.DvirReportEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description DVIR_ADMIN_CREATE_DENIED */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description DVIR_INVALID_TRANSITION */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/dvir-reports/{id}/pdf": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * DVIR report PDF
         * @description Q31 — the administrator "Generate Report" surface: a printable copy of an existing DVIR, never a new one. The document is printed with headless Chrome; when no Chrome binary is reachable the endpoint degrades to `text/html` instead of failing, so check `Content-Type`. Signature and photo files stay object storage references and are not embedded.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description DVIR report id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description Inspection report */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/pdf": string;
                        "text/html": string;
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/pdf": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                        "text/html": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/pdf": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                        "text/html": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/pdf": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                        "text/html": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/pdf": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                        "text/html": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description UPSTREAM_ERROR */
                502: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/pdf": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                        "text/html": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/dvir-reports/{id}/repair": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Record a DVIR repair
         * @description TZ §7.2 — the Service Manager transition `submitted_defects_found` → `repaired`. Q27: the mechanic signature only exists on this step. An optional invoice (number, vendor, cost, file key) is written to the maintenance history. Any other source status answers 409 `DVIR_INVALID_TRANSITION`.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description DVIR report id */
                    id: string;
                };
                cookie?: never;
            };
            /** @description Repair payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.DvirRepair"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.DvirReportEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description DVIR_INVALID_TRANSITION */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/eld-devices": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List ELD devices
         * @description Registered ELD hardware with its current unit, firmware and raised malfunction codes.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                    /** @description Sort field */
                    sort?: "serial" | "vendor" | "status" | "created_at";
                    /** @description Sort order */
                    order?: "asc" | "desc";
                    /** @description Matches serial, vendor or model */
                    search?: string;
                    /** @description Device status */
                    status?: "active" | "inactive" | "malfunction";
                    /** @description Unit filter (uuid) */
                    unit_id?: string;
                    /** @description Connection type */
                    connection_type?: "bluetooth" | "wifi" | "cellular" | "usb";
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.EldDeviceListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        /**
         * Register an ELD device
         * @description `(company_id, serial)` is unique among rows that are not soft deleted. Q3.1 — wiring the device to an inactive unit answers 409.
         */
        post: {
            parameters: {
                query?: never;
                header?: {
                    /** @description Replay protection key */
                    "Idempotency-Key"?: string;
                };
                path?: never;
                cookie?: never;
            };
            /** @description Device payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.EldDeviceCreate"];
                };
            };
            responses: {
                /** @description Created */
                201: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.EldDeviceEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION / INVALID_STATE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/eld-devices/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Get ELD device
         * @description Cross-tenant identifiers answer 404, never 403.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Device id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.EldDeviceEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        /**
         * Delete ELD device
         * @description Soft delete; the open unit assignment is closed in the same transaction and the serial becomes reusable.
         */
        delete: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Device id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description No Content */
                204: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description RESOURCE_IN_USE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        options?: never;
        head?: never;
        /**
         * Update ELD device
         * @description Partial update; omitted fields keep their stored value.
         */
        patch: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Device id */
                    id: string;
                };
                cookie?: never;
            };
            /** @description Fields to change */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.EldDeviceUpdate"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.EldDeviceEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        trace?: never;
    };
    "/eld-devices/{id}/assign-unit": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Wire an ELD device to a unit
         * @description Writes `eld_device_assignments` (from_at/to_at). A null `unit_id` detaches the device. One unit carries at most one active device (409 ALREADY_ASSIGNED) and Q3.1 forbids wiring to an inactive unit (409 INVALID_STATE).
         */
        post: {
            parameters: {
                query?: never;
                header?: {
                    /** @description Replay protection key */
                    "Idempotency-Key"?: string;
                };
                path: {
                    /** @description Device id */
                    id: string;
                };
                cookie?: never;
            };
            /** @description Target unit */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.EldDeviceAssignUnit"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.EldDeviceEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description ALREADY_ASSIGNED / INVALID_STATE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/feedback": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List app feedback
         * @description Q80 — the driver app rating stream. Feedback is never answered, so there is no detail, update or delete route.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                    /** @description Sort field */
                    sort?: "submitted_at" | "app_rating";
                    /** @description Sort order */
                    order?: "asc" | "desc";
                    /** @description Driver filter (uuid) */
                    driver_id?: string;
                    /** @description Minimum star rating (1..5) */
                    min_rating?: number;
                    /** @description Submitted at or after (RFC3339) */
                    from?: string;
                    /** @description Submitted before (RFC3339) */
                    to?: string;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.FeedbackListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        /**
         * Submit app feedback
         * @description Q80 — the driver rates the app (1..5) and/or leaves a note; at least one of the two is required. The submission gets no reply. `driver_id` is resolved from the access token.
         */
        post: {
            parameters: {
                query?: never;
                header?: {
                    /** @description Replay protection key */
                    "Idempotency-Key"?: string;
                };
                path?: never;
                cookie?: never;
            };
            /** @description Feedback payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.FeedbackCreate"];
                };
            };
            responses: {
                /** @description Created */
                201: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.FeedbackEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/files/presign": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Presign a file upload
         * @description TZ B§3.4 — the API never proxies bytes. `kind` is a closed whitelist (dvir_photo, invoice, signature, logo, chat, import); the content type and the size are checked against the per-kind ceiling (DVIR photo ≤ 5 MiB, invoice ≤ 10 MiB) before anything is signed. The object key is derived server side from the tenant, the kind and a random uuid — a client supplied path is never trusted — and only that key is stored. The URL is a PUT valid for 15 minutes; its `Content-Type` **and** `Content-Length` headers are part of the signature, so the upload must be exactly `size_bytes` long — the ceiling cannot be bypassed after presigning. Send every header of `headers` verbatim.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            /** @description Upload description */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.PresignRequest"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.PresignEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
                /** @description FILE_TOO_LARGE */
                413: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR / FILE_TYPE_INVALID */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
                /** @description STORAGE_ERROR */
                502: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
                /** @description SERVICE_UNAVAILABLE */
                503: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/inspection/begin": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Begin roadside inspection
         * @description Q54 — mints a short lived, **read only** token for the inspector. The token is a limited capability principal that holds no permission at all, so it can only reach `GET /inspection/logs`; every write endpoint, including `/inspection/email` and `/inspection/transfer`, refuses it with 403. Its lifetime is the configured access token TTL. NOTE: the TZ D§3 endpoint table does not list this route yet; it is required to issue the roadside token and needs a contract amendment.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description Created */
                201: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.InspectionSessionEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description SERVICE_UNAVAILABLE */
                503: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/inspection/email": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * E-mail the inspection report
         * @description Q55 — sends the roadside window (7 days plus today) as a PDF built from the log grid, the event list and the Log Form. The comment is optional. The read only roadside token cannot reach this endpoint: sending is a write action gated by `inspection.email`.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            /** @description Recipient and window */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.InspectionEmail"];
                };
            };
            responses: {
                /** @description Accepted */
                202: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.MessageEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description INTERNAL_ERROR */
                500: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/inspection/logs": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Roadside inspection logs
         * @description Q53 — 7 days plus today for one driver: every log day with its events, its Log Form and its violations. The endpoint accepts the read only roadside token issued by `POST /inspection/begin` as well as a normal principal holding `inspection.view`. A roadside token can do nothing else: it holds no permission, so every other route answers 403.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Driver id (uuid); a driver always reads its own logs */
                    driver_id?: string;
                    /** @description Window anchor, YYYY-MM-DD (default: today) */
                    date?: string;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.InspectionReportEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/inspection/transfer": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Transfer the inspection output file
         * @description Q56 — builds the regulator output file for the roadside window. With `regulation_profile=generic` the answer is a ZIP holding the event CSV next to the printed report. `us_fmcsa` needs the FMCSA ELD output file (§4.8.2.1), which is delivered in stage 7 and answers 501 until then. The read only roadside token cannot reach this endpoint.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            /** @description Window and comment */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.InspectionTransfer"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.InspectionTransferEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description FEATURE_DISABLED */
                501: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description STORAGE_ERROR */
                502: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/log-edit-requests": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List log edit requests
         * @description Q17 — the propose/approve queue. An administrator sees the whole company (or its branch), a Driver (scope `self`) only its own pending edits, which is the mobile "Pending edits" screen.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Status filter */
                    status?: "pending" | "approved" | "rejected";
                    /** @description Driver filter (uuid) */
                    driver_id?: string;
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.LogEditRequestListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        /**
         * Propose a log edit
         * @description TZ §5.3 / Q17 [MUST] — an administrator never rewrites a driver log directly. The proposal is stored `pending` and the driver approves or rejects it. `note` is mandatory on every change. Q17.1 is enforced already at proposal time: automatically recorded `DR` may not be shortened or re-classified (`DR_IMMUTABLE`), and `intermediate`, `power_on/off` and `malfunction` events are never editable (`EVENT_IMMUTABLE`).
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            /** @description Proposed changes */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.LogEditRequestCreate"];
                };
            };
            responses: {
                /** @description Created */
                201: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.LogEditRequestEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description DR_IMMUTABLE / EVENT_IMMUTABLE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/log-edit-requests/{id}/approve": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Approve a log edit request
         * @description Q17 — only the driver whose log is being changed may approve. The new events are written with `origin=admin_edit`, the original events are kept and flagged with `superseded_by` (nothing is deleted) and a certified day falls back to `needs_recertify` (Q18). For an `unidentified_assign` request the stored driving rows are handed over with `origin=assigned` (§10.4) and the 8 day `unidentified_driving` violation is closed.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Log edit request id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.LogEditRequestEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description INVALID_STATE / DR_IMMUTABLE / EVENT_IMMUTABLE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/log-edit-requests/{id}/reject": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Reject a log edit request
         * @description Q17 — only the driver may reject, and the reason is mandatory. The log stays exactly as it is and the administrator is told why.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Log edit request id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            /** @description Rejection reason */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.LogEditReject"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.LogEditRequestEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description INVALID_STATE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/maintenance-records": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List maintenance records
         * @description TZ §8 Q32 — the completion and cancellation history, newest first. A `cancelled` row never carries invoice, vendor or cost (Q43). Costs are decimal amounts in `currency`; the odometer stays metres.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Unit filter (uuid) */
                    unit_id?: string;
                    /** @description Record status */
                    status?: "completed" | "cancelled";
                    /**
                     * @description Start of the window (RFC3339 UTC)
                     * @example 2026-09-01T00:00:00Z
                     */
                    from?: string;
                    /**
                     * @description End of the window, exclusive (RFC3339 UTC)
                     * @example 2026-09-08T00:00:00Z
                     */
                    to?: string;
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.RecordListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/maintenance-schedule-units/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Get maintenance schedule unit
         * @description One unit's progress against one schedule, with the same computed `current_value` / `remaining` / `overdue` fields as the due list. Cross-tenant ids answer 404, never 403.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Schedule unit id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ScheduleUnitEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/maintenance-schedule-units/{id}/cancel": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Cancel a maintenance entry
         * @description TZ §8 Q43 — closes the row without any financial field; only `cancelled_reason` is stored, and a `cancelled` row is written to `/maintenance-records`. A row that is already completed or cancelled answers 409 `MAINTENANCE_INVALID_STATE`.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Schedule unit id */
                    id: string;
                };
                cookie?: never;
            };
            /** @description Cancellation payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.CancelInput"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ScheduleUnitEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description MAINTENANCE_INVALID_STATE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/maintenance-schedule-units/{id}/complete": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Complete a maintenance entry
         * @description TZ §8 Q41–Q43 — records Invoice #, Vendor, Cost, Date and the invoice file, and writes a `completed` row into `/maintenance-records`. Q42.1: `last_service_value` is set to the odometer / engine hours read **at this moment** from telemetry, the row moves Due → Schedule and gets a fresh `next_due_value = last_service_value + interval_value`; the reminder guard is cleared so the next cycle can announce again. A `days` schedule re-bases `next_due_at` on the completion date instead. A km/mi/engine_hours schedule whose unit never reported telemetry answers 422 `MAINTENANCE_NO_READING`; a row that is already completed or cancelled answers 409 `MAINTENANCE_INVALID_STATE`.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Schedule unit id */
                    id: string;
                };
                cookie?: never;
            };
            /** @description Completion payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.CompleteInput"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ScheduleUnitEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description MAINTENANCE_INVALID_STATE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR / MAINTENANCE_NO_READING / TIME_IN_FUTURE */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/maintenance-schedules": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List maintenance schedules
         * @description TZ §8 — the maintenance plans of the tenant. Q33 vocabulary: `interval_value` + `interval_unit` are the maintenance frequency and `reminder_before_value` is how far ahead of the due point the Q37 reminder fires, expressed in the same unit.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Plan status */
                    status?: "active" | "inactive";
                    /**
                     * @description Name search
                     * @example oil
                     */
                    q?: string;
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ScheduleListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        /**
         * Create maintenance schedule
         * @description TZ §8 Q39/Q40 — one plan can cover many units, and every unit keeps its own `last_service_value` / `next_due_value`. Omitting `last_service_value` on a unit seeds it from the live telemetry reading (odometer for km/mi, engine hours for engine_hours); a `days` interval is seeded from the creation date instead. Q42.1 later resets those values on completion.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            /** @description Schedule payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ScheduleCreate"];
                };
            };
            responses: {
                /** @description Created */
                201: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ScheduleEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/maintenance-schedules/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Get maintenance schedule
         * @description One maintenance plan with the number of units attached. Cross-tenant ids answer 404, never 403.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Schedule id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ScheduleEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        /**
         * Delete maintenance schedule
         * @description Soft delete (`deleted_at`); the completed and cancelled history in `/maintenance-records` is never removed (Q32).
         */
        delete: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Schedule id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description Deleted */
                204: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
            };
        };
        options?: never;
        head?: never;
        /**
         * Update maintenance schedule
         * @description Patches a plan; nil fields are left untouched. Sending `units` replaces the attached fleet: units that disappear from the list are detached, new ones are seeded like on creation. Existing progress of a unit that stays is preserved.
         */
        patch: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Schedule id */
                    id: string;
                };
                cookie?: never;
            };
            /** @description Patch payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ScheduleUpdate"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ScheduleEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
            };
        };
        trace?: never;
    };
    "/maintenance/due": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Maintenance due list
         * @description TZ §8 Q33/Q34 — one row per unit and schedule. `current_value` is read live from telemetry (odometer converted to the schedule unit, or engine hours) and from the calendar for a `days` interval; `remaining = next_due_value - current_value`, and a negative remaining sets `overdue=true` (red in the UI). `reminder_due` marks rows that reached `reminder_before_value`. By default only open rows (`scheduled`, `due`) are returned; pass `status` to inspect a closed one. `current_value` is null when the unit has never reported telemetry.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Unit filter (uuid) */
                    unit_id?: string;
                    /** @description Schedule filter (uuid) */
                    schedule_id?: string;
                    /** @description Row status */
                    status?: "scheduled" | "due" | "completed" | "cancelled";
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ScheduleUnitListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/me": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Current user
         * @description Q82 — the signed in profile with its effective permission keys and scope. Never returns a password hash, a TOTP secret or a token.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ProfileEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/notifications": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List notifications
         * @description TZ A§19 / Q87 — the caller's own inbox, newest first. The inbox is personal: there is no way to read another user's notifications. `read` filters on the read state (`true` = read only, `false` = unread only) and `alert_type` on one alert family. `meta.unread` is the badge counter and ignores both filters.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                    /** @description Read state filter */
                    read?: boolean;
                    /** @description Alert type filter */
                    alert_type?: "hos_warning" | "hos_violation" | "route_assigned" | "route_completed" | "dvir_defects" | "dvir_critical" | "log_edit_request" | "log_edit_resolved" | "uncertified_log" | "unidentified_driving" | "eld_disconnected" | "eld_malfunction" | "maintenance_upcoming" | "maintenance_overdue" | "chat_message" | "subscription_expiring";
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.NotificationListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/notifications/read-all": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Mark every notification read
         * @description Q88 — clears the badge for the calling user only.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.ReadResultEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/notifications/{id}/read": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        /**
         * Mark a notification read
         * @description Q88 — idempotent: a notification that is already read answers 200 with `updated: 0`. A notification of another user or another company answers 404, never 403.
         */
        patch: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Notification id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.ReadResultEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.ErrorResponse"];
                    };
                };
            };
        };
        trace?: never;
    };
    "/permissions": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Permission catalogue
         * @description Q82 — every RBAC key grouped by module with its description. Audit critical modules (logs, dvir, violations, telemetry, audit_log) deliberately have no `delete` key (Q82.2). Requires `permissions.read` or `roles.read`.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.PermissionListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/reports/activity": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Activity report
         * @description Q75 — Start/End odometer per driver or per unit over a window, with `odometer_change_m = end − start`. The numbers come straight from telemetry, so the report is live. Distances are metres; the backend never converts units. A subject that reported nothing in the window comes back with `has_data = false` and zeroes rather than a misleading negative change.
         */
        get: {
            parameters: {
                query: {
                    /** @description Report axis */
                    subject?: "drivers" | "units";
                    /** @description First day of the window (YYYY-MM-DD) */
                    from: string;
                    /** @description Last day of the window, inclusive (YYYY-MM-DD) */
                    to: string;
                    /** @description Unit filter (uuid, repeatable) */
                    unit_id?: string;
                    /** @description Driver filter (uuid, repeatable) */
                    driver_id?: string;
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ActivityListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/reports/distance-by-region": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Distance by Region report
         * @description TZ §14 — the quarterly per jurisdiction distance (IFTA style). It is served from the daily `unit_region_distance_daily` roll-up, so the answer is immediate; the roll-up itself is filled by a nightly job that intersects the telemetry track with the PostGIS region polygons. `regions_and_units` breaks the distance down per unit, `regions_only` returns one row per region. Distances are metres.
         */
        get: {
            parameters: {
                query: {
                    /** @description Calendar quarter (1-4) */
                    quarter: number;
                    /** @description Calendar year */
                    year: number;
                    /** @description Breakdown */
                    mode?: "regions_and_units" | "regions_only";
                    /** @description Unit filter (uuid, repeatable) */
                    unit_id?: string;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.DistanceByRegionEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/reports/export-jobs": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List export jobs
         * @description The requester's export history, newest first. Finished jobs carry a `download_url` while they are inside their 24 hour window (Q75).
         */
        get: {
            parameters: {
                query?: {
                    /** @description Job status */
                    status?: "queued" | "running" | "done" | "failed";
                    /** @description Report type */
                    type?: "distance_by_region" | "regulator" | "activity" | "hos" | "dvir";
                    /** @description Only the jobs this user requested */
                    mine?: boolean;
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ExportJobListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        /**
         * Queue a report export
         * @description Q75 — every export is asynchronous: the job is queued, a worker renders it, the file lands in object storage and the requester is notified. `GET /reports/export-jobs/{id}` then carries a download link that is valid for 24 hours. The regulator export is gated on the tenant's regulation profile: `generic` produces a PDF + CSV archive, every FMCSA profile answers 501 FEATURE_DISABLED until the FMCSA output file and web service ship. Creating and downloading an export are both written to the audit log.
         */
        post: {
            parameters: {
                query?: never;
                header?: {
                    /** @description Replay protection key */
                    "Idempotency-Key"?: string;
                };
                path?: never;
                cookie?: never;
            };
            /** @description Export request */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ExportJobCreate"];
                };
            };
            responses: {
                /** @description Accepted */
                202: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ExportJobEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse"];
                    };
                };
                /** @description IDEMPOTENCY_CONFLICT */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse"];
                    };
                };
                /** @description FEATURE_DISABLED */
                501: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/reports/export-jobs/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Get an export job
         * @description Q75 — the job state and, once it is `done`, a presigned `download_url` that expires with the file after 24 hours. An expired job keeps its metadata but no link. A job of another company answers 404, never 403.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Export job id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ExportJobEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/reports/uncertified-logs": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Uncertified logs report
         * @description Q19.1 — the log days that left the 8 day certification window without a signature. They disappear from the driver's list but stay in this admin alert; `days_overdue` counts the calendar days past the window.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Driver filter (uuid) */
                    driver_id?: string;
                    /** @description Branch filter (uuid) */
                    branch_id?: string;
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.UncertifiedLogListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/roles": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List roles
         * @description Q81 — the system templates (`is_system: true`, shared by every company) plus the roles this company defined. System roles can be read but never edited or deleted.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Page number */
                    page?: number;
                    /** @description Page size (max 100) */
                    per_page?: number;
                    /** @description Sort field */
                    sort?: "name" | "scope" | "created_at";
                    /** @description Sort direction */
                    order?: "asc" | "desc";
                    /** @description Scope filter */
                    scope?: "company" | "branch" | "self";
                    /** @description Only system or only custom roles */
                    is_system?: boolean;
                    /** @description Role name */
                    search?: string;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.RoleListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        /**
         * Create a role
         * @description Q82 — every permission key must exist in GET /permissions; unknown keys and any `delete` key of an audit critical module (logs, dvir, violations, telemetry, audit_log) are rejected with 422.
         */
        post: {
            parameters: {
                query?: never;
                header?: {
                    /** @description Optional idempotency key */
                    "Idempotency-Key"?: string;
                };
                path?: never;
                cookie?: never;
            };
            /** @description Role payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.RoleCreate"];
                };
            };
            responses: {
                /** @description Created */
                201: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.RoleEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION — the role name is taken */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR — unknown permission key */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/roles/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        post?: never;
        /**
         * Delete a role
         * @description Q81 — soft delete. A role that still has users answers 409 ROLE_IN_USE; a system role answers 403 SYSTEM_ROLE_IMMUTABLE.
         */
        delete: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Role id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description No Content */
                204: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description SYSTEM_ROLE_IMMUTABLE / FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND — unknown or cross-tenant record */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description ROLE_IN_USE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
            };
        };
        options?: never;
        head?: never;
        /**
         * Update a role
         * @description Q81/B§3.1 — a system role answers 403 SYSTEM_ROLE_IMMUTABLE. Any change invalidates the cached permission set and revokes the sessions of every holder, so a narrowed role takes effect immediately.
         */
        patch: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Role id */
                    id: string;
                };
                cookie?: never;
            };
            /** @description Partial role payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.RoleUpdate"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.RoleEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description SYSTEM_ROLE_IMMUTABLE / FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND — unknown or cross-tenant record */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR — unknown permission key */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
            };
        };
        trace?: never;
    };
    "/routes": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List routes
         * @description Q66–Q68 — the trip planner queue. A route is created `ongoing` and leaves that state either through the destination geofence (`completed`) or through an admin closure (`not_completed`). Several routes may queue on one unit; `sequence` orders them and only the lowest ongoing sequence is the current one.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                    /** @description Sort field */
                    sort?: "created_at" | "sequence" | "status";
                    /** @description Sort order */
                    order?: "asc" | "desc";
                    /** @description Route status */
                    status?: "ongoing" | "completed" | "not_completed" | "cancelled";
                    /** @description Unit filter (uuid) */
                    unit_id?: string;
                    /** @description Driver filter (uuid) */
                    driver_id?: string;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.RouteListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        /**
         * Create route
         * @description Q66 — the route is created `ongoing`; there is no manual start. `geofence_m` defaults to 300 m and is the radius that completes the route once the unit has stayed inside it for two minutes. `sequence` defaults to the next free slot of the unit (Q68). The assigned driver receives a push notification (Q66.1). A unit or driver of another company answers 404.
         */
        post: {
            parameters: {
                query?: never;
                header?: {
                    /** @description Replay protection key */
                    "Idempotency-Key"?: string;
                };
                path?: never;
                cookie?: never;
            };
            /** @description Route payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.RouteCreate"];
                };
            };
            responses: {
                /** @description Created */
                201: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.RouteEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description IDEMPOTENCY_CONFLICT */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/routes/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Get route
         * @description Q66 — one trip planner entry. A route of another company answers 404, never 403.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Route id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.RouteEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        /**
         * Delete route
         * @description Soft delete (`deleted_at`); the row stays for the audit trail.
         */
        delete: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Route id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description No Content */
                204: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "*/*": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "*/*": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "*/*": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "*/*": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "*/*": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
            };
        };
        options?: never;
        head?: never;
        /**
         * Update route
         * @description Q66 — only an `ongoing` route can be edited; a terminal route is a record and answers 409 INVALID_STATE. Changing `driver_id` re-notifies the new driver.
         */
        patch: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Route id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            /** @description Partial route payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.RouteUpdate"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.RouteEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description INVALID_STATE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
            };
        };
        trace?: never;
    };
    "/routes/{id}/directions": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Get route directions
         * @description Q66.1 — the driving geometry between origin and destination, taken from the configured map provider (TZ B§7.3). The answer is cached per origin/destination pair, so repeated opens cost no provider call. When no provider is configured the payload comes back empty with `provider = nop` instead of failing.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Route id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.DirectionsEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description INVALID_STATE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description SERVICE_UNAVAILABLE */
                503: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/routes/{id}/not-completed": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Close route as not completed
         * @description Q66 — the admin closure of an ongoing route. `reason` comes from the fixed list; `other` requires a note. A route that is not `ongoing` answers 409 INVALID_STATE.
         */
        post: {
            parameters: {
                query?: never;
                header?: {
                    /** @description Replay protection key */
                    "Idempotency-Key"?: string;
                };
                path: {
                    /** @description Route id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            /** @description Closure payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.RouteNotCompleted"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.RouteEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description INVALID_STATE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/shipping-documents": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /** List shipping documents */
        get: {
            parameters: {
                query?: {
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                    /** @description Matches the document number */
                    search?: string;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ShippingDocumentListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        /**
         * Create shipping document
         * @description `(company_id, number)` is unique among rows that are not soft deleted.
         */
        post: {
            parameters: {
                query?: never;
                header?: {
                    /** @description Replay protection key */
                    "Idempotency-Key"?: string;
                };
                path?: never;
                cookie?: never;
            };
            /** @description Shipping document payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.CatalogCreate"];
                };
            };
            responses: {
                /** @description Created */
                201: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ShippingDocumentEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/shipping-documents/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Get shipping document
         * @description Cross-tenant identifiers answer 404, never 403.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Shipping document id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ShippingDocumentEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        /**
         * Delete shipping document
         * @description Soft delete; the number becomes reusable.
         */
        delete: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Shipping document id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description No Content */
                204: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description RESOURCE_IN_USE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        options?: never;
        head?: never;
        /** Update shipping document */
        patch: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Shipping document id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody: components["requestBodies"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.CatalogUpdate"];
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ShippingDocumentEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        trace?: never;
    };
    "/support-tickets": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List support tickets
         * @description Q77 — the company help desk queue. A driver (`self` scope) only ever sees the tickets it filed or that were filed for it, whatever `driver_id` says.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                    /** @description Sort field */
                    sort?: "created_at" | "status" | "subject";
                    /** @description Sort order */
                    order?: "asc" | "desc";
                    /** @description Lifecycle filter */
                    status?: "new" | "in_progress" | "resolved" | "closed";
                    /** @description Driver filter (uuid), ignored for a driver principal */
                    driver_id?: string;
                    /** @description Matches the subject */
                    search?: string;
                    /** @description Created at or after (RFC3339) */
                    from?: string;
                    /** @description Created before (RFC3339) */
                    to?: string;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.TicketListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        /**
         * Create support ticket
         * @description Q77 — required: subject. `contact_on` picks the answer channel (Q78) and `attachments` carries at most three storage file keys returned by the upload endpoint. The reporter is taken from the access token: `driver_id` is resolved from the caller and never accepted from the body.
         */
        post: {
            parameters: {
                query?: never;
                header?: {
                    /** @description Replay protection key */
                    "Idempotency-Key"?: string;
                };
                path?: never;
                cookie?: never;
            };
            /** @description Ticket payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.TicketCreate"];
                };
            };
            responses: {
                /** @description Created */
                201: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.TicketEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN, SUBSCRIPTION_READONLY */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/support-tickets/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Get support ticket
         * @description Cross-tenant identifiers and another driver's ticket both answer 404, never 403, so ids cannot be probed.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Ticket id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.TicketEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/support-tickets/{id}/messages": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List ticket thread messages
         * @description Q77 [SHOULD] — the admin answer lives inside the ticket. Oldest first.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                };
                header?: never;
                path: {
                    /** @description Ticket id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.TicketMessageListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        /**
         * Reply inside a support ticket
         * @description Q77 [SHOULD] — appends one entry to the ticket thread; at most three attachments. A driver may only write into a ticket it owns; every other ticket answers 404.
         */
        post: {
            parameters: {
                query?: never;
                header?: {
                    /** @description Replay protection key */
                    "Idempotency-Key"?: string;
                };
                path: {
                    /** @description Ticket id */
                    id: string;
                };
                cookie?: never;
            };
            /** @description Message payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.TicketMessageCreate"];
                };
            };
            responses: {
                /** @description Created */
                201: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.TicketMessageEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN, SUBSCRIPTION_READONLY */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/support-tickets/{id}/status": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        /**
         * Change support ticket status
         * @description Q77 — the lifecycle only moves forward: `new → in_progress → resolved`. Any backward or repeated transition answers 409 INVALID_STATE. Every change is written to `audit_log`.
         */
        patch: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Ticket id */
                    id: string;
                };
                cookie?: never;
            };
            /** @description New status */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.TicketStatusUpdate"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.TicketEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN, SUBSCRIPTION_READONLY */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description INVALID_STATE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse"];
                    };
                };
            };
        };
        trace?: never;
    };
    "/sync/pull": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Download server changes
         * @description TZ D§2 — everything the device has to catch up on since `since`: pending log edit requests, the unidentified driving buffer of the driver's unit (A§10.4), the server's canonical copies of changed duty status events and log days (conflict rule 2 — the server wins and the device rebuilds its local log), the current `hos_policy`, the DVIR defect catalogue, the quick-note templates and new chat messages. `next_since` is the newest `updated_at` actually returned, so a truncated page (`truncated=true`) resumes exactly where it stopped. Without `since` the default window is the last 8 days. A Driver reads its own data only.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Cursor from the previous pull, RFC3339 */
                    since?: string;
                    /** @description Unit the driver is logged into; selects the unidentified driving buffer */
                    unit_id?: string;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.PullEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN — the caller is not a driver */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/sync/push": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Upload an offline batch
         * @description TZ D§2 — the driver app drains its offline queue here. Each element is answered individually with `accepted`, `duplicate` or `rejected(reason)`; a duplicate `client_event_id` is never an error. Conflict rules: an event more than five minutes ahead of the server is `rejected(time_in_future)`; an event on a certified day is `rejected(log_locked)`; two devices claiming the same instant are resolved by `time_source` priority (eld_rtc > server > phone) then by the larger `device_seq`, and the loser is still stored with `superseded_by` set and reported as `accepted` with `reason=superseded`. The server also enforces the duty rules it owns: PC/YM need `hos_policy.allow_pc`/`allow_ym`, SB needs a sleeper berth on the unit, DR is never selected by hand, and motion at or above `motion_threshold_kmh` coerces the status to DR. Ceilings: 500 events, 5000 telemetry points, 100 DVIR, 500 chat. `Idempotency-Key` is required. DVIR and chat elements are acknowledged but only processed from stages 5-6 on.
         */
        post: {
            parameters: {
                query?: never;
                header: {
                    /** @description Idempotency key; a repeat replays the recorded response for 24h */
                    "Idempotency-Key": string;
                };
                path?: never;
                cookie?: never;
            };
            /** @description Offline batch */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.PushRequest"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.PushEnvelope"];
                    };
                };
                /** @description BAD_REQUEST — Idempotency-Key missing */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN — the caller is not a driver */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.ErrorResponse"];
                    };
                };
                /** @description IDEMPOTENCY_CONFLICT */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR, BATCH_TOO_LARGE */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/tracking/live": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Live tracking map
         * @description TZ §10.1 / Q63 — the last known state of every unit, read from `unit_last_state`. `online_status` is Online (telemetry within 5 minutes), Offline, Disconnected (the ELD reported losing the phone link) or Malfunction (the wired ELD carries an active FMCSA Appendix A code, which wins over the connectivity state). A branch scoped principal always sees its own branch only. Distances are metres and speeds km/h; the backend never converts units. The `online_status` filter matches the stored connectivity state, so `malfunction` is not a filter value.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                    /** @description Comma separated unit ids (max 500) */
                    unit_ids?: string;
                    /** @description Branch filter (uuid) */
                    branch_id?: string;
                    /** @description Connectivity filter */
                    online_status?: "online" | "idle" | "offline" | "disconnected";
                    /** @description Include inactive units */
                    include_inactive?: boolean;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.LiveUnitListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/trailers": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /** List trailers */
        get: {
            parameters: {
                query?: {
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                    /** @description Matches the trailer number */
                    search?: string;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.TrailerListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        /**
         * Create trailer
         * @description `(company_id, number)` is unique among rows that are not soft deleted.
         */
        post: {
            parameters: {
                query?: never;
                header?: {
                    /** @description Replay protection key */
                    "Idempotency-Key"?: string;
                };
                path?: never;
                cookie?: never;
            };
            /** @description Trailer payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.CatalogCreate"];
                };
            };
            responses: {
                /** @description Created */
                201: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.TrailerEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/trailers/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Get trailer
         * @description Cross-tenant identifiers answer 404, never 403.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Trailer id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.TrailerEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        /**
         * Delete trailer
         * @description Soft delete; the number becomes reusable.
         */
        delete: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Trailer id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description No Content */
                204: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description RESOURCE_IN_USE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        options?: never;
        head?: never;
        /** Update trailer */
        patch: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Trailer id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody: components["requestBodies"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.CatalogUpdate"];
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.TrailerEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        trace?: never;
    };
    "/trips/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Get trip
         * @description Trip detail with its track. `polyline` is a Google encoded polyline (precision 5) rebuilt from the telemetry of the trip window; `polyline_key` is the object storage key of the copy written when the trip closed, which outlives the telemetry retention window. Pass `include_polyline=false` to skip the rebuild. Cross-tenant and out of scope trip ids answer 404, never 403.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Rebuild the polyline from telemetry */
                    include_polyline?: boolean;
                };
                header?: never;
                path: {
                    /** @description Trip id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.TripEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/unidentified-events": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List unidentified driving events
         * @description TZ A§10.4 — driving recorded without an identified driver is buffered here (unit, start/end, distance, track). Assigning an event to a driver or claiming it from the mobile app happens through the log edit request flow, not on this endpoint. `pending_days` beyond 8 raises the admin alert.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Resolution status */
                    status?: "pending" | "assigned" | "annotated";
                    /** @description Unit filter (uuid) */
                    unit_id?: string;
                    /**
                     * @description Start of the window (RFC3339 UTC)
                     * @example 2026-09-01T00:00:00Z
                     */
                    from?: string;
                    /**
                     * @description End of the window, exclusive (RFC3339 UTC)
                     * @example 2026-09-08T00:00:00Z
                     */
                    to?: string;
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.UnidentifiedEventListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/unidentified-events/{id}/annotate": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Annotate an unidentified driving block
         * @description TZ §10.4 — the administrator leaves the block unassigned with an explanation, for example a mechanic's test drive. The block moves to `annotated` and stops counting towards the 8 day alert. The annotation is mandatory.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Unidentified event id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            /** @description Explanation */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.UnidentifiedAnnotate"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.UnidentifiedEventEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description INVALID_STATE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/unidentified-events/{id}/assign": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Assign an unidentified driving block
         * @description TZ §10.4 — the administrator proposes the block to a driver; it does **not** move yet. A `log_edit_requests` row with `source=unidentified_assign` is created and the block waits in `proposed` until the driver approves it (the same propose/approve model as §5.3). `note` is mandatory. Rejecting the request puts the block back to `pending`. `GET /unidentified-events` itself lives in the tracking module.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            /** @description Unidentified event id (uuid) */
            requestBody: {
                content: {
                    "application/json": string;
                };
            };
            responses: {
                /** @description Created */
                201: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.LogEditRequestEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description ALREADY_ASSIGNED */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/unidentified-events/{id}/claim": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Claim an unidentified driving block
         * @description TZ §10.4 — the driver takes an unassigned block itself, which needs no second approval. The stored driving rows keep their identity and gain `origin=assigned`; they are attached to the driver's log day, the totals are recomputed, a certified day falls back to `needs_recertify` and the 8 day `unidentified_driving` violation is closed. A block proposed to another driver answers 409.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Unidentified event id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.UnidentifiedEventEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description ALREADY_ASSIGNED */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/units": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List units
         * @description Q1/Q2 — only active units are returned unless `include_inactive=true`. A branch scoped principal always sees its own branch only. `odometer_m` is the last telemetry reading in metres; the backend never converts units.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                    /** @description Sort field */
                    sort?: "unit_number" | "status" | "make" | "year" | "created_at";
                    /** @description Sort order */
                    order?: "asc" | "desc";
                    /** @description Matches unit_number, vin or license_plate */
                    search?: string;
                    /** @description Activity status */
                    status?: "active" | "inactive";
                    /** @description Branch filter (uuid) */
                    branch_id?: string;
                    /** @description Out of service filter */
                    out_of_service?: boolean;
                    /** @description Include inactive units */
                    include_inactive?: boolean;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        /**
         * Create unit
         * @description Q18.1 — required: unit_number, make, model, license_plate, fuel_type. VIN is optional and validated as 17 characters when present. `(company_id, unit_number)` and `(company_id, vin)` are unique among rows that are not soft deleted.
         */
        post: {
            parameters: {
                query?: never;
                header?: {
                    /** @description Replay protection key */
                    "Idempotency-Key"?: string;
                };
                path?: never;
                cookie?: never;
            };
            /** @description Unit payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitCreate"];
                };
            };
            responses: {
                /** @description Created */
                201: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/units/export": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Export units
         * @description Downloads the unit list as CSV (default) or XLSX. Every download is recorded in `audit_log`.
         */
        get: {
            parameters: {
                query?: {
                    /** @description File format */
                    format?: "csv" | "xlsx";
                    /** @description Unit status */
                    status?: "active" | "inactive";
                    /** @description Branch id (uuid) */
                    branch_id?: string;
                    /** @description Include deactivated units */
                    include_inactive?: boolean;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description CSV or XLSX file */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "text/csv": string;
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "text/csv": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "text/csv": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "text/csv": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/units/import": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Import units from CSV/XLSX
         * @description TZ §18.4 — multipart upload of `units_import_template` (unit_number, make, model, year, plate, plate_region, vin, fuel_type, sleeper_berth). Validation is row by row and **all-or-nothing**: one critical error and nothing at all is written; the body then lists every `{row, field, message}` and the response status is 422.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody: components["requestBodies"]["postDriversImport"];
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ImportResultEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
                /** @description PAYLOAD_TOO_LARGE */
                413: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR — nothing was written */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ImportResultEnvelope"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/units/import-template": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Download the unit import template
         * @description TZ §18.4 — `units_import_template` with the exact column order the importer expects, plus one sample row.
         */
        get: {
            parameters: {
                query?: {
                    /** @description File format */
                    format?: "csv" | "xlsx";
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description CSV or XLSX file */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "text/csv": string;
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "text/csv": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "text/csv": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "text/csv": components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/units/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Get unit
         * @description Cross-tenant and out of scope identifiers answer 404, never 403.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Unit id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        /**
         * Delete unit
         * @description Q1 — soft delete (`deleted_at`). Related logs, DVIR reports and telemetry are kept; the unit_number and VIN become reusable.
         */
        delete: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Unit id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description No Content */
                204: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description RESOURCE_IN_USE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        options?: never;
        head?: never;
        /**
         * Update unit
         * @description Partial update; omitted fields keep their stored value. Renaming into an existing unit_number or vin answers 409.
         */
        patch: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Unit id */
                    id: string;
                };
                cookie?: never;
            };
            /** @description Fields to change */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitUpdate"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        trace?: never;
    };
    "/units/{id}/activate": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Activate unit
         * @description Q1 — the active ⇄ inactive transition is reversible and audited.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Unit id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/units/{id}/assign-driver": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Assign a driver to a unit
         * @description Q1.1 — a unit holds one open assignment per role, so assigning a new `primary` closes the previous one. An inactive unit or driver answers 409.
         */
        post: {
            parameters: {
                query?: never;
                header?: {
                    /** @description Replay protection key */
                    "Idempotency-Key"?: string;
                };
                path: {
                    /** @description Unit id */
                    id: string;
                };
                cookie?: never;
            };
            /** @description Driver and role */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitAssignDriver"];
                };
            };
            responses: {
                /** @description Created */
                201: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitAssignmentEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description INVALID_STATE / ACCOUNT_INACTIVE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/units/{id}/deactivate": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Deactivate unit
         * @description Q3.1 — an inactive unit accepts no ELD connection and no driver assignment.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Unit id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/units/{id}/diagnostics": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Unit ELD diagnostics
         * @description TZ §10.1/§10.5 — `connection_state` is Online when telemetry is younger than five minutes, Offline when it is older, Disconnected when the device reported the link is down and Malfunction when any FMCSA code (P/E/T/L/R/S/O) is raised. Telemetry values are raw: distance in metres, speed in km/h.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Unit id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitDiagnosticsEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/units/{id}/history": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Unit history
         * @description Q3 — the audit_log entries of the unit merged with its driver assignment history, newest first.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Inclusive lower bound (RFC3339 UTC) */
                    from?: string;
                    /** @description Exclusive upper bound (RFC3339 UTC) */
                    to?: string;
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page */
                    per_page?: number;
                };
                header?: never;
                path: {
                    /** @description Unit id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitHistoryEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/units/{id}/trips": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List unit trips of a day
         * @description TZ §13 Q64/Q65 — a trip runs from ignition on to ignition off, or ends after a stop of 15 minutes or more. The `date` window is the calendar day in the **company timezone**, converted to UTC; omitting it means today. Cross-tenant and out of scope unit ids answer 404, never 403.
         */
        get: {
            parameters: {
                query?: {
                    /**
                     * @description Calendar day in the company timezone (YYYY-MM-DD)
                     * @example 2026-09-06
                     */
                    date?: string;
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                };
                header?: never;
                path: {
                    /** @description Unit id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.TripListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/users": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List users
         * @description Q1/Q82.1 — a branch scoped caller only ever sees its own branch, whatever `branch_id` says. Never returns a password hash, a TOTP secret or a PIN.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Page number */
                    page?: number;
                    /** @description Page size (max 100) */
                    per_page?: number;
                    /** @description Sort field */
                    sort?: "last_name" | "first_name" | "username" | "email" | "status" | "created_at";
                    /** @description Sort direction */
                    order?: "asc" | "desc";
                    /** @description Activity filter */
                    status?: "invited" | "active" | "inactive";
                    /** @description Role filter */
                    role_id?: string;
                    /** @description Branch filter */
                    branch_id?: string;
                    /** @description Name, username, email or phone */
                    search?: string;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.UserListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        /**
         * Invite a user
         * @description Q81/A§16 — there is no password field: the account is created with status `invited` and a 72 hour invitation link is delivered by email or SMS. Either `email` or `phone` is required.
         */
        post: {
            parameters: {
                query?: never;
                header?: {
                    /** @description Optional idempotency key */
                    "Idempotency-Key"?: string;
                };
                path?: never;
                cookie?: never;
            };
            /** @description User payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.UserCreate"];
                };
            };
            responses: {
                /** @description Created */
                201: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.UserEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND — unknown role or branch */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION — username or email already used */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/users/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        post?: never;
        /**
         * Delete a user
         * @description Q1 — soft delete: `deleted_at` is stamped, related logs and DVIR records are kept. You cannot delete your own account, nor the last active Administrator of the company.
         */
        delete: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description User id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description No Content */
                204: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND — unknown or cross-tenant record */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description SELF_TARGET_FORBIDDEN / LAST_ADMINISTRATOR */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
            };
        };
        options?: never;
        head?: never;
        /**
         * Update a user
         * @description Q82.1 — changing the role revokes every session of the account so the new permission set applies immediately. Activity state is changed with the activate / deactivate endpoints, not here.
         */
        patch: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description User id */
                    id: string;
                };
                cookie?: never;
            };
            /** @description Partial user payload */
            requestBody: {
                content: {
                    "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.UserUpdate"];
                };
            };
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.UserEnvelope"];
                    };
                };
                /** @description BAD_REQUEST */
                400: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND — unknown or cross-tenant record */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description UNIQUE_VIOLATION */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
            };
        };
        trace?: never;
    };
    "/users/{id}/activate": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Activate a user
         * @description Q1 — active ⇄ inactive is reversible. An account that has not accepted its invitation cannot be activated: resend the invitation instead.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description User id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.UserEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND — unknown or cross-tenant record */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description INVALID_STATE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/users/{id}/deactivate": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Deactivate a user
         * @description Q3.1 — an inactive user cannot sign in (403 ACCOUNT_INACTIVE) and every session of the account is revoked immediately. You cannot deactivate yourself or the last active Administrator.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description User id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.UserEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND — unknown or cross-tenant record */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description SELF_TARGET_FORBIDDEN / LAST_ADMINISTRATOR */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/users/{id}/resend-invitation": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Resend the invitation link
         * @description A§16 — a fresh 72 hour link is issued and the previous one is invalidated. The token itself is delivered out of band and never appears in the response.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description User id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description Accepted */
                202: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.InvitationEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND — unknown or cross-tenant record */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description INVALID_STATE — the invitation was already accepted */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/users/{id}/reset-password": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /**
         * Send a password reset link
         * @description A§16 — an administrator never sets a password: this endpoint only re-sends a one time link, exactly like the invitation flow. An inactive account is rejected.
         */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description User id */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description Accepted */
                202: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.InvitationEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND — unknown or cross-tenant record */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description ACCOUNT_INACTIVE */
                409: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/violations": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * List violations
         * @description Q57/Q58 — the canonical violation history. Violations are created on the server only (the mobile app previews them) and are **never deleted**: a closed one keeps `resolved_at` and `resolved_reason` and stays in the list. Q59: the filters are independent of each other. Closing rules: `break_required` after a qualifying break, `drive_limit`/`shift_limit` after a daily rest, `cycle_limit` after a restart or when the day drops out of the cycle window, `form_manner_*` when the field is filled in and the log is certified again, `uncertified_log` on signature and `unidentified_driving` on assignment.
         */
        get: {
            parameters: {
                query?: {
                    /** @description Driver filter (uuid) */
                    driver_id?: string;
                    /** @description Violation type */
                    type?: "form_manner_trailer" | "form_manner_doc" | "drive_limit" | "shift_limit" | "break_required" | "cycle_limit" | "uncertified_log" | "unidentified_driving" | "eld_malfunction" | "missing_dvir";
                    /** @description Severity */
                    severity?: "warning" | "violation";
                    /** @description Only resolved (true) or only open (false) */
                    resolved?: boolean;
                    /** @description Occurred from, RFC3339 */
                    from?: string;
                    /** @description Occurred before, RFC3339 */
                    to?: string;
                    /** @description Page number */
                    page?: number;
                    /** @description Rows per page (10/25/50, max 100) */
                    per_page?: number;
                };
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ViolationListEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description VALIDATION_ERROR */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/violations/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /**
         * Violation detail
         * @description Q57 — one stored violation with the policy version it was judged under (Q10.1) and, once closed, its `resolved_reason` (Q58). The row is never removed.
         */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    /** @description Violation id (uuid) */
                    id: string;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description OK */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ViolationEnvelope"];
                    };
                };
                /** @description UNAUTHORIZED */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description FORBIDDEN */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description NOT_FOUND */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
                /** @description RATE_LIMITED */
                429: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse"];
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
}
export type webhooks = Record<string, never>;
export interface components {
    schemas: {
        "github_com_devline_onebook-eld_internal_domain_auditlog_dto.Entry": {
            /**
             * @example update
             * @enum {string}
             */
            action?: "insert" | "create" | "update" | "soft_delete" | "delete" | "restore" | "login" | "logout" | "failed_login" | "export" | "permission_change" | "log_edit_request" | "hos_policy_change" | "token_reuse" | "cross_tenant_attempt" | "certify" | "assign" | "approve" | "reject" | "license_reveal";
            /**
             * @description EditedBy is the acting user, null for system jobs.
             * @example 8d3e2f1a-4b5c-4d6e-9f70-1a2b3c4d5e6f
             */
            edited_by?: string;
            /** @example Anna Ross */
            edited_by_name?: string;
            /** @example status */
            field?: string;
            /** @example 3c9a1f2e-5d4b-4a6c-8e1f-0d2b3a4c5e6f */
            id?: string;
            /** @example 203.0.113.24 */
            ip?: string;
            /**
             * @description Masked reports that at least one of the two values was redacted.
             * @example false
             */
            masked?: boolean;
            /**
             * @description NewValue is the masked value after the change, null on delete.
             * @example in_progress
             */
            new_value?: string;
            /**
             * @description OldValue is the masked value before the change, null on insert. The
             *     stored shape is whatever the audited column held (a string, a number, a
             *     JSON object); swag cannot type an `any`, so the schema renders it as a
             *     free form string.
             * @example new
             */
            old_value?: string;
            /** @example driver requested correction */
            reason?: string;
            /**
             * @description RecordID is the audited row, null for account wide events such as login.
             * @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f
             */
            record_id?: string;
            /**
             * @description TableName is the audited table, e.g. `units` or `support_tickets`.
             * @example support_tickets
             */
            table?: string;
            /**
             * Format: date-time
             * @example 2026-09-07T11:30:00Z
             */
            ts?: string;
            /** @example Mozilla/5.0 */
            user_agent?: string;
            /** @example anna.ross */
            username?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_auditlog_dto.EntryListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_auditlog_dto.Entry"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_auditlog_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_auditlog_dto.ErrorResponse": {
            error?: components["schemas"]["github_com_devline_onebook-eld_internal_httpx_dto.ErrorBody"];
        };
        "github_com_devline_onebook-eld_internal_domain_auditlog_dto.Meta": {
            /** @example 1 */
            page?: number;
            /** @example 25 */
            per_page?: number;
            /** @example 123 */
            total?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_auditlog_dto.TableListEnvelope": {
            /**
             * @example [
             *       "support_tickets"
             *     ]
             */
            data?: string[];
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.AppConfig": {
            /**
             * @description AccessTokenTTLSeconds lets a client schedule its refresh.
             * @example 900
             */
            access_token_ttl_seconds?: number;
            /** @description FeatureFlags toggles optional modules per deployment. */
            feature_flags?: {
                [key: string]: boolean;
            };
            /** @example false */
            force_update?: boolean;
            /** @example 1.4.2 */
            latest_version?: string;
            /** @example 1.0.0 */
            min_supported_version?: string;
            /**
             * Format: date-time
             * @description ServerTime lets the client detect clock drift before signing events.
             * @example 2026-09-06T05:12:00Z
             */
            server_time?: string;
            /**
             * @description SupportEmail is shown on the mobile about screen.
             * @example support@onebook-eld.com
             */
            support_email?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.AppConfigEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.AppConfig"];
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.ErrorResponse": {
            error?: components["schemas"]["github_com_devline_onebook-eld_internal_httpx_dto.ErrorBody"];
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.InvitationAcceptRequest": {
            /** @example Str0ngPassphrase */
            password: string;
            /**
             * @description PIN optionally sets the 6 digit driver PIN in the same call.
             * @example 483920
             */
            pin?: string;
            /** @example Zr4KpN1vQ8sT2mL5xB7cD0eF3gH6jI9k */
            token: string;
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.LoginEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.LoginResult"];
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.LoginRequest": {
            /** @example 1.4.2 */
            app_version?: string;
            /**
             * @description CompanyID disambiguates a username that exists in several tenants. It is
             *     a pre-authentication hint only: the effective tenant always comes from
             *     the resolved user row, never from this field.
             * @example 3f7c2d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f
             */
            company_id?: string;
            /** @example 7c9f2f1e-2b4a-4f7d-9a1e-0f2b3c4d5e6f */
            device_id?: string;
            /**
             * @description DeviceType decides which of the three concurrent session slots is used.
             * @example web
             * @enum {string}
             */
            device_type: "web" | "phone" | "tablet";
            /** @example Str0ngPassphrase */
            password: string;
            /**
             * @description TOTPCode is required once two factor authentication is enabled.
             * @example 123456
             */
            totp_code?: string;
            /** @example jdoe */
            username: string;
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.LoginResult": {
            /** @example eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIifQ.sig */
            access_token?: string;
            /**
             * @description ExpiresIn is the access token lifetime in seconds.
             * @example 900
             */
            expires_in?: number;
            /**
             * Format: date-time
             * @description RefreshExpiresAt is when the refresh window closes.
             * @example 2026-10-06T05:12:00Z
             */
            refresh_expires_at?: string;
            /**
             * @description RefreshToken is empty while the session is limited to 2FA enrolment.
             * @example o1Wm4c9vJ3xQ7pL0aZ2bY5nR8tK6sD4fH1gU3jE
             */
            refresh_token?: string;
            /**
             * @description ReplacedSession reports that another session of the same device type was
             *     revoked by this login (TZ A§20).
             * @example false
             */
            replaced_session?: boolean;
            /**
             * @description RequiresTOTPSetup marks a limited token: the account must enrol in two
             *     factor authentication before anything else is permitted.
             * @example false
             */
            requires_totp_setup?: boolean;
            /**
             * @description SessionID identifies the session created by this login.
             * @example 9e2c4a1b-7d3f-4e5a-8b6c-0d1e2f3a4b5c
             */
            session_id?: string;
            /**
             * @description SubscriptionReadonly reports that the company subscription lapsed and
             *     only read operations are accepted.
             * @example false
             */
            subscription_readonly?: boolean;
            /** @example Bearer */
            token_type?: string;
            user?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.Profile"];
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.LogoutRequest": {
            /**
             * @description Pause keeps the session recoverable with a PIN (Leave Truck).
             * @example false
             */
            pause?: boolean;
            /**
             * @description RefreshToken optionally targets one session explicitly.
             * @example o1Wm4c9vJ3xQ7pL0aZ2bY5nR8tK6sD4fH1gU3jE
             */
            refresh_token?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.MessageEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.MessageResponse"];
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.MessageResponse": {
            /** @example ok */
            message?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.Meta": {
            /** @example 1 */
            page?: number;
            /** @example 25 */
            per_page?: number;
            /** @example 123 */
            total?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.PINVerified": {
            /**
             * @example return_to_truck
             * @enum {string}
             */
            action?: "switch_driver" | "return_to_truck";
            /**
             * @description SessionResumed reports that a paused session was reactivated.
             * @example true
             */
            session_resumed?: boolean;
            /** @example true */
            verified?: boolean;
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.PINVerifiedEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.PINVerified"];
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.PINVerifyRequest": {
            /**
             * @description Action selects what the verified PIN unlocks.
             * @example return_to_truck
             * @enum {string}
             */
            action?: "switch_driver" | "return_to_truck";
            /** @example 483920 */
            pin: string;
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.PasswordForgotRequest": {
            /**
             * @description Login is the username or the email address of the account.
             * @example jdoe
             */
            login: string;
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.PasswordResetRequest": {
            /** @example Str0ngPassphrase */
            password: string;
            /** @example Zr4KpN1vQ8sT2mL5xB7cD0eF3gH6jI9k */
            token: string;
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.Profile": {
            /** @example 8a7b6c5d-4e3f-2a1b-0c9d-8e7f6a5b4c3d */
            branch_id?: string;
            /**
             * @description CompanyID is empty for platform (super admin) accounts.
             * @example 3f7c2d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f
             */
            company_id?: string;
            /**
             * @description Email is masked for anyone but the account owner.
             * @example j***e@example.com
             */
            email?: string;
            /** @example John */
            first_name?: string;
            /** @example 5c1d2e3f-4a5b-6c7d-8e9f-0a1b2c3d4e5f */
            id?: string;
            /** @example false */
            is_super_admin?: boolean;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            last_login_at?: string;
            /** @example Doe */
            last_name?: string;
            /**
             * @example [
             *       "units.read",
             *       "drivers.read"
             *     ]
             */
            permissions?: string[];
            /** @example true */
            pin_set?: boolean;
            /** @example 1b2c3d4e-5f6a-7b8c-9d0e-1f2a3b4c5d6e */
            role_id?: string;
            /** @example Fleet Manager */
            role_name?: string;
            /**
             * @example company
             * @enum {string}
             */
            scope?: "company" | "branch" | "self";
            /**
             * @example active
             * @enum {string}
             */
            status?: "invited" | "active" | "inactive";
            /** @example true */
            totp_enabled?: boolean;
            /** @example jdoe */
            username?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.ProfileEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.Profile"];
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.RefreshRequest": {
            /** @example 1.4.2 */
            app_version?: string;
            /** @example o1Wm4c9vJ3xQ7pL0aZ2bY5nR8tK6sD4fH1gU3jE */
            refresh_token: string;
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.Session": {
            /** @example 1.4.2 */
            app_version?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            created_at?: string;
            /** @example true */
            current?: boolean;
            /** @example 7c9f2f1e-2b4a-4f7d-9a1e-0f2b3c4d5e6f */
            device_id?: string;
            /**
             * @example phone
             * @enum {string}
             */
            device_type?: "web" | "phone" | "tablet";
            /**
             * Format: date-time
             * @example 2026-10-06T05:12:00Z
             */
            expires_at?: string;
            /** @example 9e2c4a1b-7d3f-4e5a-8b6c-0d1e2f3a4b5c */
            id?: string;
            /**
             * @description IP is truncated; the full address stays in the audit trail only.
             * @example 203.0.113.0
             */
            ip?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T07:40:00Z
             */
            last_seen_at?: string;
            /**
             * @example active
             * @enum {string}
             */
            status?: "active" | "paused" | "revoked";
            /** @example ONEBOOK-ELD/1.4.2 (Android 14) */
            user_agent?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.SessionListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.Session"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.TOTPSetup": {
            /**
             * @description Digits and Period describe the expected authenticator configuration.
             * @example 6
             */
            digits?: number;
            /** @example ONEBOOK ELD */
            issuer?: string;
            /**
             * @description OtpauthURL is rendered as a QR code by the client.
             * @example otpauth://totp/ONEBOOK%20ELD:jdoe?secret=JBSWY3DPEHPK3PXP&issuer=ONEBOOK%20ELD
             */
            otpauth_url?: string;
            /** @example 30 */
            period?: number;
            /**
             * @description Secret is the base32 value for manual entry. It is shown once and is
             *     stored AES-256-GCM encrypted.
             * @example JBSWY3DPEHPK3PXP
             */
            secret?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.TOTPSetupEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.TOTPSetup"];
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.TOTPVerified": {
            /** @example true */
            enabled?: boolean;
            /**
             * @description RecoveryCodes are shown exactly once, at enrolment. Only their hashes
             *     are stored and each code works a single time.
             * @example [
             *       "3f9a1c2d4e6b8a0c1d2e",
             *       "7b1c9d0e2f3a4b5c6d7e"
             *     ]
             */
            recovery_codes?: string[];
            /** @description Tokens is filled when the verification upgraded a limited session. */
            tokens?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.Tokens"];
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.TOTPVerifiedEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.TOTPVerified"];
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.TOTPVerifyRequest": {
            /** @example 123456 */
            code?: string;
            /**
             * @description RecoveryCode is accepted instead of Code when the device is lost.
             * @example 3f9a1c2d4e6b8a0c1d2e
             */
            recovery_code?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.Tokens": {
            /** @example eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIifQ.sig */
            access_token?: string;
            /**
             * @description ExpiresIn is the access token lifetime in seconds.
             * @example 900
             */
            expires_in?: number;
            /**
             * Format: date-time
             * @description RefreshExpiresAt is when the refresh window closes.
             * @example 2026-10-06T05:12:00Z
             */
            refresh_expires_at?: string;
            /**
             * @description RefreshToken is empty while the session is limited to 2FA enrolment.
             * @example o1Wm4c9vJ3xQ7pL0aZ2bY5nR8tK6sD4fH1gU3jE
             */
            refresh_token?: string;
            /** @example Bearer */
            token_type?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_auth_dto.TokensEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_auth_dto.Tokens"];
        };
        "github_com_devline_onebook-eld_internal_domain_chat_dto.CursorMeta": {
            /**
             * @description HasMore reports whether older messages exist.
             * @example true
             */
            has_more?: boolean;
            /**
             * Format: date-time
             * @description NextBefore is the cursor to pass as ?before for the next (older) page.
             * @example 2026-09-06T17:40:00Z
             */
            next_before?: string;
            /**
             * @description PerPage is the requested page size.
             * @example 50
             */
            per_page?: number;
            /**
             * @description Unread is the number of unread messages the caller has in this thread.
             * @example 2
             */
            unread?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_chat_dto.ErrorResponse": {
            error?: components["schemas"]["github_com_devline_onebook-eld_internal_httpx_dto.ErrorBody"];
        };
        "github_com_devline_onebook-eld_internal_domain_chat_dto.Message": {
            /**
             * Format: date-time
             * @example 2026-09-06T18:05:04Z
             */
            delivered_at?: string;
            /** @example 1f9d7c2a-4c66-4c2f-9d2f-9a0b7d1e2f34 */
            driver_id?: string;
            /** @example chat/2026/09/6f1a1a5e.pdf */
            file_key?: string;
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            id?: string;
            /**
             * @example text
             * @enum {string}
             */
            kind?: "text" | "image" | "file" | "location";
            /** @example 31.5204 */
            lat?: number;
            /** @example 74.3587 */
            lng?: number;
            /**
             * Format: date-time
             * @example 2026-09-06T18:07:11Z
             */
            read_at?: string;
            /** @example 3a2b1c0d-9e8f-4a5b-8c7d-6e5f4a3b2c1d */
            sender_id?: string;
            /**
             * @example office
             * @enum {string}
             */
            sender_side?: "driver" | "office";
            /**
             * Format: date-time
             * @example 2026-09-06T18:05:00Z
             */
            sent_at?: string;
            /**
             * @example delivered
             * @enum {string}
             */
            status?: "sent" | "delivered" | "read";
            /** @example Please head to dock 4 after your break. */
            text?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_chat_dto.MessageCreate": {
            /**
             * @description FileKey is the storage key returned by POST /files/presign; required for
             *     image and file messages.
             * @example chat/2026/09/6f1a1a5e.pdf
             */
            file_key?: string;
            /**
             * @example text
             * @enum {string}
             */
            kind: "text" | "image" | "file" | "location";
            /**
             * @description Lat and Lng are required for a location message.
             * @example 31.5204
             */
            lat?: number;
            /** @example 74.3587 */
            lng?: number;
            /**
             * @description Text is required for a text message and optional as a caption otherwise.
             * @example Please head to dock 4 after your break.
             */
            text?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_chat_dto.MessageEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.Message"];
        };
        "github_com_devline_onebook-eld_internal_domain_chat_dto.MessageListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.Message"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.CursorMeta"];
        };
        "github_com_devline_onebook-eld_internal_domain_chat_dto.Meta": {
            /** @example 1 */
            page?: number;
            /** @example 25 */
            per_page?: number;
            /** @example 123 */
            total?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_chat_dto.ReadResult": {
            /** @example 0 */
            unread?: number;
            /** @example 1 */
            updated?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_chat_dto.ReadResultEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.ReadResult"];
        };
        "github_com_devline_onebook-eld_internal_domain_chat_dto.Thread": {
            /** @example 1f9d7c2a-4c66-4c2f-9d2f-9a0b7d1e2f34 */
            driver_id?: string;
            /** @example John Doe */
            driver_name?: string;
            /**
             * @example active
             * @enum {string}
             */
            driver_status?: "active" | "inactive";
            last_message?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.Message"];
            /** @example 3 */
            unread_count?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_chat_dto.ThreadListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.Thread"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_chat_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_companies_dto.AdminCompanyEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.Company"];
        };
        "github_com_devline_onebook-eld_internal_domain_companies_dto.AdminCompanyListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.Company"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_companies_dto.AdministratorInvite": {
            /**
             * @description Channel selects how the invitation link is delivered.
             * @example email
             * @enum {string}
             */
            channel?: "email" | "sms" | "telegram";
            /** @example jane.doe@onebook.example */
            email: string;
            /** @example Jane */
            first_name: string;
            /** @example Doe */
            last_name: string;
            /** @example +15125550143 */
            phone?: string;
            /**
             * @description Username defaults to the local part of the email address.
             * @example jane.doe
             */
            username?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_companies_dto.Company": {
            /** @example 1200 Industrial Rd, Dallas, TX 75207 */
            address?: string;
            /**
             * Format: date-time
             * @example 2026-01-14T09:30:00Z
             */
            created_at?: string;
            /** @example ops@onebook.example */
            email?: string;
            /** @example 1200 Industrial Rd, Dallas, TX 75207 */
            home_terminal_address?: string;
            /** @example 3f7c2d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f */
            id?: string;
            /** @example companies/3f7c2d1a/logo.png */
            logo_key?: string;
            /** @example Onebook Logistics LLC */
            name?: string;
            /** @example +15125550143 */
            phone?: string;
            /** @example fleet_50 */
            plan?: string;
            /**
             * @example US
             * @enum {string}
             */
            region?: "PK" | "UZ" | "US" | "other";
            /** @example 3928471 */
            registration_no?: string;
            /**
             * @example us_fmcsa
             * @enum {string}
             */
            regulation_profile?: "us_fmcsa" | "generic" | "canada" | "texas" | "california" | "alaska" | "hawaii";
            settings?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.Settings"];
            /**
             * Format: date-time
             * @example 2026-12-31T23:59:59Z
             */
            subscription_end_at?: string;
            /**
             * @example active
             * @enum {string}
             */
            subscription_status?: "trial" | "active" | "grace" | "readonly";
            /** @example America/Chicago */
            timezone?: string;
            /**
             * @example imperial
             * @enum {string}
             */
            unit_system?: "metric" | "imperial";
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            updated_at?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_companies_dto.CompanyCreate": {
            /** @example 1200 Industrial Rd, Dallas, TX 75207 */
            address?: string;
            administrator: components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.AdministratorInvite"];
            /** @example ops@onebook.example */
            email?: string;
            /** @example 1200 Industrial Rd, Dallas, TX 75207 */
            home_terminal_address?: string;
            /** @example Onebook Logistics LLC */
            name: string;
            /** @example +15125550143 */
            phone?: string;
            /** @example fleet_50 */
            plan?: string;
            /**
             * @example US
             * @enum {string}
             */
            region: "PK" | "UZ" | "US" | "other";
            /** @example 3928471 */
            registration_no?: string;
            /**
             * @example us_fmcsa
             * @enum {string}
             */
            regulation_profile: "us_fmcsa" | "generic" | "canada" | "texas" | "california" | "alaska" | "hawaii";
            /**
             * Format: date-time
             * @example 2026-12-31T23:59:59Z
             */
            subscription_end_at?: string;
            /**
             * @example trial
             * @enum {string}
             */
            subscription_status?: "trial" | "active" | "grace" | "readonly";
            /** @example America/Chicago */
            timezone: string;
            /**
             * @example imperial
             * @enum {string}
             */
            unit_system: "metric" | "imperial";
        };
        "github_com_devline_onebook-eld_internal_domain_companies_dto.CompanyCreated": {
            /**
             * @description AdministratorRoleID is the company's copy of the Administrator role.
             * @example 11f0a1b2-c3d4-4e5f-8a9b-0c1d2e3f4a5b
             */
            administrator_role_id?: string;
            /**
             * @description AdministratorUserID is the invited Administrator account.
             * @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f
             */
            administrator_user_id?: string;
            company?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.Company"];
            /**
             * @description InvitationChannel is how the link was delivered.
             * @example email
             * @enum {string}
             */
            invitation_channel?: "email" | "sms" | "telegram";
            /**
             * Format: date-time
             * @description InvitationExpiresAt is when the invitation link stops working (72 h).
             * @example 2026-09-09T05:12:00Z
             */
            invitation_expires_at?: string;
            /**
             * @description RolesCreated is the number of system role templates copied.
             * @example 8
             */
            roles_created?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_companies_dto.CompanyCreatedEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_companies_dto.CompanyCreated"];
        };
        "github_com_devline_onebook-eld_internal_domain_companies_dto.CompanyUpdate": {
            /** @example 1200 Industrial Rd, Dallas, TX 75207 */
            address?: string;
            /** @example ops@onebook.example */
            email?: string;
            /** @example 1200 Industrial Rd, Dallas, TX 75207 */
            home_terminal_address?: string;
            /** @example companies/3f7c2d1a/logo.png */
            logo_key?: string;
            /** @example Onebook Logistics LLC */
            name?: string;
            /** @example +15125550143 */
            phone?: string;
            /** @example fleet_50 */
            plan?: string;
            /**
             * @example US
             * @enum {string}
             */
            region?: "PK" | "UZ" | "US" | "other";
            /** @example 3928471 */
            registration_no?: string;
            /**
             * @example us_fmcsa
             * @enum {string}
             */
            regulation_profile?: "us_fmcsa" | "generic" | "canada" | "texas" | "california" | "alaska" | "hawaii";
            /** @example America/Chicago */
            timezone?: string;
            /**
             * @example imperial
             * @enum {string}
             */
            unit_system?: "metric" | "imperial";
        };
        "github_com_devline_onebook-eld_internal_domain_companies_dto.ErrorResponse": {
            error?: components["schemas"]["github_com_devline_onebook-eld_internal_httpx_dto.ErrorBody"];
        };
        "github_com_devline_onebook-eld_internal_domain_companies_dto.Meta": {
            /** @example 1 */
            page?: number;
            /** @example 25 */
            per_page?: number;
            /** @example 123 */
            total?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_companies_dto.SubscriptionUpdate": {
            /**
             * @description ClearEndAt removes subscription_end_at (perpetual / internal tenants).
             * @example false
             */
            clear_end_at?: boolean;
            /** @example fleet_50 */
            plan?: string;
            /**
             * Format: date-time
             * @description EndAt is the moment the paid period ends. Send null together with
             *     clear_end_at to drop the date entirely.
             * @example 2026-12-31T23:59:59Z
             */
            subscription_end_at?: string;
            /**
             * @example active
             * @enum {string}
             */
            subscription_status?: "trial" | "active" | "grace" | "readonly";
        };
        "github_com_devline_onebook-eld_internal_domain_company_dto.Branch": {
            /** @example 1200 Industrial Rd, Dallas, TX 75207 */
            address?: string;
            /**
             * Format: date-time
             * @example 2026-01-14T09:30:00Z
             */
            created_at?: string;
            /** @example 9c1d5e7a-2b3c-4d5e-8f90-1a2b3c4d5e6f */
            id?: string;
            /** @example Dallas Terminal */
            name?: string;
            /** @example America/Chicago */
            timezone?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            updated_at?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_company_dto.BranchCreate": {
            /** @example 1200 Industrial Rd, Dallas, TX 75207 */
            address?: string;
            /** @example Dallas Terminal */
            name: string;
            /** @example America/Chicago */
            timezone?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_company_dto.BranchEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.Branch"];
        };
        "github_com_devline_onebook-eld_internal_domain_company_dto.BranchListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.Branch"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_company_dto.BranchUpdate": {
            /** @example 1200 Industrial Rd, Dallas, TX 75207 */
            address?: string;
            /** @example Dallas Terminal */
            name?: string;
            /** @example America/Chicago */
            timezone?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_company_dto.Company": {
            /** @example 1200 Industrial Rd, Dallas, TX 75207 */
            address?: string;
            /**
             * Format: date-time
             * @example 2026-01-14T09:30:00Z
             */
            created_at?: string;
            /** @example ops@onebook.example */
            email?: string;
            /** @example 1200 Industrial Rd, Dallas, TX 75207 */
            home_terminal_address?: string;
            /** @example 3f7c2d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f */
            id?: string;
            /** @example companies/3f7c2d1a/logo.png */
            logo_key?: string;
            /** @example Onebook Logistics LLC */
            name?: string;
            /** @example +15125550143 */
            phone?: string;
            /** @example fleet_50 */
            plan?: string;
            /**
             * @example US
             * @enum {string}
             */
            region?: "PK" | "UZ" | "US" | "other";
            /** @example 3928471 */
            registration_no?: string;
            /**
             * @example us_fmcsa
             * @enum {string}
             */
            regulation_profile?: "us_fmcsa" | "generic" | "canada" | "texas" | "california" | "alaska" | "hawaii";
            settings?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.Settings"];
            /**
             * Format: date-time
             * @example 2026-12-31T23:59:59Z
             */
            subscription_end_at?: string;
            /**
             * @example active
             * @enum {string}
             */
            subscription_status?: "trial" | "active" | "grace" | "readonly";
            /** @example America/Chicago */
            timezone?: string;
            /**
             * @example imperial
             * @enum {string}
             */
            unit_system?: "metric" | "imperial";
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            updated_at?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_company_dto.CompanyEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.Company"];
        };
        "github_com_devline_onebook-eld_internal_domain_company_dto.CompanyUpdate": {
            /** @example 1200 Industrial Rd, Dallas, TX 75207 */
            address?: string;
            /** @example ops@onebook.example */
            email?: string;
            /** @example 1200 Industrial Rd, Dallas, TX 75207 */
            home_terminal_address?: string;
            /** @example companies/3f7c2d1a/logo.png */
            logo_key?: string;
            /** @example Onebook Logistics LLC */
            name?: string;
            /** @example +15125550143 */
            phone?: string;
            /**
             * @example US
             * @enum {string}
             */
            region?: "PK" | "UZ" | "US" | "other";
            /** @example 3928471 */
            registration_no?: string;
            /**
             * @example us_fmcsa
             * @enum {string}
             */
            regulation_profile?: "us_fmcsa" | "generic" | "canada" | "texas" | "california" | "alaska" | "hawaii";
            settings?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.Settings"];
            /** @example America/Chicago */
            timezone?: string;
            /**
             * @example imperial
             * @enum {string}
             */
            unit_system?: "metric" | "imperial";
        };
        "github_com_devline_onebook-eld_internal_domain_company_dto.ErrorResponse": {
            error?: components["schemas"]["github_com_devline_onebook-eld_internal_httpx_dto.ErrorBody"];
        };
        "github_com_devline_onebook-eld_internal_domain_company_dto.HistoryEntry": {
            /**
             * @example update
             * @enum {string}
             */
            action?: "create" | "update" | "delete" | "soft_delete" | "hos_policy_change" | "subscription_change";
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            edited_by?: string;
            /** @example Jane Doe */
            edited_by_name?: string;
            /** @example timezone */
            field?: string;
            /** @example 2d4f6a8c-1e3b-4d5f-9a7c-8b6d4e2f0a1c */
            id?: string;
            /** @example America/Denver */
            new_value?: string;
            /** @example America/Chicago */
            old_value?: string;
            /** @example 3f7c2d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f */
            record_id?: string;
            /** @example companies */
            table_name?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            ts?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_company_dto.HistoryListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.HistoryEntry"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_company_dto.HosPolicy": {
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            created_at?: string;
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            created_by?: string;
            /**
             * Format: date-time
             * @example 2026-10-01T00:00:00Z
             */
            effective_from?: string;
            /** @example 5b2e8f10-7c3d-4a1b-9e6f-2c3d4e5f6a7b */
            id?: string;
            policy?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.HosPolicyDoc"];
        };
        "github_com_devline_onebook-eld_internal_domain_company_dto.HosPolicyCreate": {
            /**
             * Format: date-time
             * @description EffectiveFrom must not be in the past: retroactive violations are
             *     forbidden. Omitted means "now".
             * @example 2026-10-01T00:00:00Z
             */
            effective_from?: string;
            policy: components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.HosPolicyDocInput"];
        };
        "github_com_devline_onebook-eld_internal_domain_company_dto.HosPolicyDoc": {
            /** @example 120 */
            adverse_conditions_extension_min?: number;
            /** @example true */
            allow_pc?: boolean;
            /** @example true */
            allow_ym?: boolean;
            /** @example 30 */
            break_duration_min?: number;
            /**
             * @example [
             *       "OFF",
             *       "SB",
             *       "ON"
             *     ]
             */
            break_qualifying_statuses?: ("OFF" | "SB" | "ON" | "DR")[];
            /** @example 480 */
            break_required_after_drive_min?: number;
            /** @example 8 */
            cycle_days?: number;
            /** @example 4200 */
            cycle_limit_min?: number;
            /** @example 2040 */
            cycle_restart_min?: number;
            /** @example 600 */
            daily_rest_min?: number;
            /** @example 660 */
            drive_limit_min?: number;
            /** @example 8 */
            motion_threshold_kmh?: number;
            /** @example 840 */
            shift_window_min?: number;
            /** @example false */
            short_haul_exception?: boolean;
            /** @example true */
            sleeper_berth_available?: boolean;
            /** @example true */
            sleeper_split_enabled?: boolean;
            warning_thresholds?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.WarningThresholds"];
            /** @example 32 */
            ym_max_speed_kmh?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_company_dto.HosPolicyDocInput": {
            /** @example 120 */
            adverse_conditions_extension_min?: number;
            /** @example true */
            allow_pc?: boolean;
            /** @example true */
            allow_ym?: boolean;
            /** @example 30 */
            break_duration_min?: number;
            /**
             * @example [
             *       "OFF",
             *       "SB",
             *       "ON"
             *     ]
             */
            break_qualifying_statuses?: ("OFF" | "SB" | "ON" | "DR")[];
            /** @example 480 */
            break_required_after_drive_min?: number;
            /** @example 8 */
            cycle_days?: number;
            /** @example 4200 */
            cycle_limit_min?: number;
            /** @example 2040 */
            cycle_restart_min?: number;
            /** @example 600 */
            daily_rest_min?: number;
            /** @example 660 */
            drive_limit_min?: number;
            /** @example 8 */
            motion_threshold_kmh?: number;
            /** @example 840 */
            shift_window_min?: number;
            /** @example false */
            short_haul_exception?: boolean;
            /** @example true */
            sleeper_berth_available?: boolean;
            /** @example true */
            sleeper_split_enabled?: boolean;
            warning_thresholds?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.WarningThresholdsInput"];
            /** @example 32 */
            ym_max_speed_kmh?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_company_dto.HosPolicyEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.HosPolicy"];
        };
        "github_com_devline_onebook-eld_internal_domain_company_dto.Meta": {
            /** @example 1 */
            page?: number;
            /** @example 25 */
            per_page?: number;
            /** @example 123 */
            total?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_company_dto.NotificationSetting": {
            /**
             * @example hos_violation
             * @enum {string}
             */
            alert_type?: "hos_warning" | "hos_violation" | "route_assigned" | "route_completed" | "dvir_defects" | "dvir_critical" | "log_edit_request" | "log_edit_resolved" | "uncertified_log" | "unidentified_driving" | "eld_disconnected" | "eld_malfunction" | "maintenance_upcoming" | "maintenance_overdue" | "chat_message" | "subscription_expiring";
            /**
             * @example [
             *       "push",
             *       "email"
             *     ]
             */
            channels?: ("push" | "email" | "sms" | "telegram")[];
            /** @example true */
            enabled?: boolean;
            /**
             * @example [
             *       "6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"
             *     ]
             */
            recipient_roles?: string[];
        };
        "github_com_devline_onebook-eld_internal_domain_company_dto.NotificationSettingUpdate": {
            /**
             * @example hos_violation
             * @enum {string}
             */
            alert_type: "hos_warning" | "hos_violation" | "route_assigned" | "route_completed" | "dvir_defects" | "dvir_critical" | "log_edit_request" | "log_edit_resolved" | "uncertified_log" | "unidentified_driving" | "eld_disconnected" | "eld_malfunction" | "maintenance_upcoming" | "maintenance_overdue" | "chat_message" | "subscription_expiring";
            /**
             * @example [
             *       "push",
             *       "email"
             *     ]
             */
            channels?: ("push" | "email" | "sms" | "telegram")[];
            /** @example true */
            enabled?: boolean;
            /**
             * @example [
             *       "6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"
             *     ]
             */
            recipient_roles?: string[];
        };
        "github_com_devline_onebook-eld_internal_domain_company_dto.NotificationSettingsEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.NotificationSetting"][];
        };
        "github_com_devline_onebook-eld_internal_domain_company_dto.NotificationSettingsUpdate": {
            settings: components["schemas"]["github_com_devline_onebook-eld_internal_domain_company_dto.NotificationSettingUpdate"][];
        };
        "github_com_devline_onebook-eld_internal_domain_company_dto.Settings": {
            /**
             * @description DistanceRegionsSet selects the region catalogue used by the distance
             *     report (Q0.1).
             * @example us_states
             * @enum {string}
             */
            distance_regions_set?: "us_states" | "pk_provinces" | "uz_regions" | "none";
            /**
             * @description FuelTypes limits the values a unit may declare.
             * @example [
             *       "diesel",
             *       "petrol",
             *       "cng",
             *       "lpg",
             *       "electric",
             *       "hybrid"
             *     ]
             */
            fuel_types?: string[];
            /**
             * @description QuickNotes are the note presets offered on the duty status form (Q1.3).
             * @example [
             *       "PTI",
             *       "Hook",
             *       "Pickup",
             *       "Drop-off",
             *       "Delivery"
             *     ]
             */
            quick_notes?: string[];
        };
        "github_com_devline_onebook-eld_internal_domain_company_dto.WarningThresholds": {
            /** @example 30 */
            break?: number;
            /** @example 120 */
            cycle?: number;
            /** @example 30 */
            drive?: number;
            /** @example 60 */
            shift?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_company_dto.WarningThresholdsInput": {
            /** @example 30 */
            break?: number;
            /** @example 120 */
            cycle?: number;
            /** @example 30 */
            drive?: number;
            /** @example 60 */
            shift?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_dashboard_dto.ErrorResponse": {
            error?: components["schemas"]["github_com_devline_onebook-eld_internal_httpx_dto.ErrorBody"];
        };
        "github_com_devline_onebook-eld_internal_domain_dashboard_dto.KPI": {
            /**
             * @description ActiveDrivers is the denominator of the status block.
             * @example 44
             */
            active_drivers?: number;
            /**
             * @description ActiveUnits counts the units that reported telemetry today.
             * @example 38
             */
            active_units?: number;
            /**
             * @description DisconnectedELD counts the units whose ELD reported losing the link.
             * @example 2
             */
            disconnected_eld?: number;
            /**
             * @description DriversOnDuty counts the drivers currently in ON or DR.
             * @example 21
             */
            drivers_on_duty?: number;
            /**
             * @description MalfunctionELD counts the devices carrying an active FMCSA code.
             * @example 1
             */
            malfunction_eld?: number;
            /**
             * @description PendingLogEdits counts the log edit requests waiting for a decision.
             * @example 2
             */
            pending_log_edits?: number;
            /**
             * @description UnassignedDriving counts the unidentified driving events still pending.
             * @example 3
             */
            unassigned_driving?: number;
            /**
             * @description UncertifiedLogs counts the logs uncertified for two days or more.
             * @example 6
             */
            uncertified_logs?: number;
            /**
             * @description Violations counts the violations of the current ISO week.
             * @example 4
             */
            violations?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_dashboard_dto.Route": {
            /**
             * Format: date-time
             * @example 2026-09-06T19:41:00Z
             */
            completed_at?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T11:00:00Z
             */
            created_at?: string;
            /** @example Oklahoma City, OK */
            destination?: string;
            /** @example 1f9d7c2a-4c66-4c2f-9d2f-9a0b7d1e2f34 */
            driver_id?: string;
            /** @example John Doe */
            driver_name?: string;
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            id?: string;
            /** @example Dallas, TX */
            origin?: string;
            /** @example 1 */
            sequence?: number;
            /**
             * Format: date-time
             * @example 2026-09-06T13:05:00Z
             */
            started_at?: string;
            /**
             * @example in_progress
             * @enum {string}
             */
            status?: "planned" | "in_progress" | "completed" | "not_completed" | "cancelled";
            /** @example 2b7c8d9e-1122-3344-5566-778899aabbcc */
            unit_id?: string;
            /** @example 1021 */
            unit_number?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_dashboard_dto.StatusBlock": {
            /** @example 12 */
            dr?: number;
            /** @example 18 */
            off?: number;
            /** @example 9 */
            on?: number;
            /** @example 5 */
            sb?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_dashboard_dto.Summary": {
            day?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_dashboard_dto.Window"];
            /**
             * Format: date-time
             * @description GeneratedAt lets a 60 second poller detect a stale payload.
             * @example 2026-09-06T18:05:00Z
             */
            generated_at?: string;
            kpi?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_dashboard_dto.KPI"];
            routes?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_dashboard_dto.Route"][];
            status?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_dashboard_dto.StatusBlock"];
            /**
             * @description Timezone is the company timezone the windows were cut in.
             * @example America/Chicago
             */
            timezone?: string;
            week?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_dashboard_dto.Window"];
        };
        "github_com_devline_onebook-eld_internal_domain_dashboard_dto.SummaryEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_dashboard_dto.Summary"];
        };
        "github_com_devline_onebook-eld_internal_domain_dashboard_dto.Window": {
            /**
             * Format: date-time
             * @example 2026-09-06T05:00:00Z
             */
            from?: string;
            /**
             * Format: date-time
             * @example 2026-09-07T05:00:00Z
             */
            to?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_drivers_dto.Activity": {
            /**
             * @example update
             * @enum {string}
             */
            action?: "create" | "update" | "soft_delete" | "login" | "logout" | "failed_login" | "export" | "activate" | "deactivate" | "password_reset" | "session_active" | "session_paused" | "session_revoked";
            /** @example 1b2c3d4e-5f60-4718-92a3-b4c5d6e7f809 */
            actor_id?: string;
            /** @example status */
            field?: string;
            /** @example 6c5b4a39-2817-4655-9483-a2b1c0d9e8f7 */
            id?: string;
            /** @example "inactive" */
            new_value?: string;
            /**
             * Format: date-time
             * @example 2026-09-05T18:22:00Z
             */
            occurred_at?: string;
            /** @example "active" */
            old_value?: string;
            /**
             * @example drivers
             * @enum {string}
             */
            source?: "drivers" | "users" | "sessions" | "audit";
            /** @example ONEBOOK-ELD/2.4.1 (iOS 18) */
            user_agent?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_drivers_dto.ActivityListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.Activity"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_drivers_dto.CoDriver": {
            /** @example a1b2c3d4-e5f6-4071-8293-a4b5c6d7e8f9 */
            driver_id?: string;
            /** @example Maria */
            first_name?: string;
            /** @example Lopez */
            last_name?: string;
            /** @example 0c1d2e3f-4a5b-4c6d-8e7f-90a1b2c3d4e5 */
            pair_id?: string;
            /**
             * Format: date-time
             * @example 2026-03-02T10:15:00Z
             */
            paired_at?: string;
            /**
             * @example active
             * @enum {string}
             */
            status?: "invited" | "active" | "inactive";
            /** @example maria.lopez */
            username?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_drivers_dto.CoDriverCreate": {
            /** @example a1b2c3d4-e5f6-4071-8293-a4b5c6d7e8f9 */
            co_driver_id: string;
        };
        "github_com_devline_onebook-eld_internal_domain_drivers_dto.CoDriverListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.CoDriver"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_drivers_dto.Driver": {
            /**
             * Format: date-time
             * @example 2026-01-14T09:00:00Z
             */
            activated_on?: string;
            /** @example 1200 Main St */
            address1?: string;
            /** @example Suite 4 */
            address2?: string;
            /** @example 2.4.1 */
            app_version?: string;
            /** @example 3f2a1b0c-4d5e-6f70-8192-a3b4c5d6e7f8 */
            branch_id?: string;
            /** @example North Terminal */
            branch_name?: string;
            /** @example Dallas */
            city?: string;
            /**
             * Format: date-time
             * @example 2026-01-14T08:59:00Z
             */
            created_at?: string;
            /** @example 5e6f7081-92a3-4b4c-95d6-e7f8091a2b3c */
            default_unit_id?: string;
            /** @example 1021 */
            default_unit_number?: string;
            /** @example john.doe@example.com */
            email?: string;
            /** @example John */
            first_name?: string;
            /** @example 9a8b7c6d-5e4f-4031-a2b3-c4d5e6f70819 */
            fleet_manager_id?: string;
            /** @example Jane Smith */
            fleet_manager_name?: string;
            /** @example Dallas Yard */
            home_terminal?: string;
            /** @example 7c3b6d3e-9a1f-4a2a-8f0c-2c1d4e5f6a7b */
            id?: string;
            /**
             * Format: date-time
             * @example 2026-09-05T18:22:00Z
             */
            last_login_at?: string;
            /** @example Doe */
            last_name?: string;
            /** @example ***4821 */
            license_no_masked?: string;
            /** @example TX */
            license_region?: string;
            /** @example Prefers night shifts */
            notes?: string;
            /** @example +14155550123 */
            phone?: string;
            /** @example TX */
            state?: string;
            /**
             * @example active
             * @enum {string}
             */
            status?: "invited" | "active" | "inactive";
            /**
             * Format: date-time
             * @example 2026-02-01T12:00:00Z
             */
            updated_at?: string;
            /** @example 1b2c3d4e-5f60-4718-92a3-b4c5d6e7f809 */
            user_id?: string;
            /**
             * @example active
             * @enum {string}
             */
            user_status?: "invited" | "active" | "inactive";
            /** @example john.doe */
            username?: string;
            /** @example 75201 */
            zip?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_drivers_dto.DriverCreate": {
            /** @example 1200 Main St */
            address1?: string;
            /** @example Suite 4 */
            address2?: string;
            /** @example 3f2a1b0c-4d5e-6f70-8192-a3b4c5d6e7f8 */
            branch_id?: string;
            /** @example Dallas */
            city?: string;
            /**
             * @description CoDriverID is optional (Q18.1) and creates a symmetric driver_pairs row.
             * @example a1b2c3d4-e5f6-4071-8293-a4b5c6d7e8f9
             */
            co_driver_id?: string;
            /** @example 5e6f7081-92a3-4b4c-95d6-e7f8091a2b3c */
            default_unit_id?: string;
            /** @example john.doe@example.com */
            email?: string;
            /** @example John */
            first_name: string;
            /** @example 9a8b7c6d-5e4f-4031-a2b3-c4d5e6f70819 */
            fleet_manager_id?: string;
            /** @example Dallas Yard */
            home_terminal?: string;
            /** @example Doe */
            last_name: string;
            /** @example TX-9930-4821 */
            license_no: string;
            /** @example TX */
            license_region?: string;
            /** @example Prefers night shifts */
            notes?: string;
            /** @example +14155550123 */
            phone?: string;
            /** @example TX */
            state?: string;
            /** @example john.doe */
            username: string;
            /** @example 75201 */
            zip?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_drivers_dto.DriverEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.Driver"];
        };
        "github_com_devline_onebook-eld_internal_domain_drivers_dto.DriverLicense": {
            /** @example 7c3b6d3e-9a1f-4a2a-8f0c-2c1d4e5f6a7b */
            driver_id?: string;
            /** @example TX-9930-4821 */
            license_no?: string;
            /** @example TX */
            license_region?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_drivers_dto.DriverLicenseEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.DriverLicense"];
        };
        "github_com_devline_onebook-eld_internal_domain_drivers_dto.DriverListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.Driver"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_drivers_dto.DriverUpdate": {
            /** @example 1200 Main St */
            address1?: string;
            /** @example Suite 4 */
            address2?: string;
            /** @example 3f2a1b0c-4d5e-6f70-8192-a3b4c5d6e7f8 */
            branch_id?: string;
            /** @example Dallas */
            city?: string;
            /** @example 5e6f7081-92a3-4b4c-95d6-e7f8091a2b3c */
            default_unit_id?: string;
            /** @example john.doe@example.com */
            email?: string;
            /** @example John */
            first_name?: string;
            /** @example 9a8b7c6d-5e4f-4031-a2b3-c4d5e6f70819 */
            fleet_manager_id?: string;
            /** @example Dallas Yard */
            home_terminal?: string;
            /** @example Doe */
            last_name?: string;
            /** @example TX-9930-4821 */
            license_no?: string;
            /** @example TX */
            license_region?: string;
            /** @example Prefers night shifts */
            notes?: string;
            /** @example +14155550123 */
            phone?: string;
            /** @example TX */
            state?: string;
            /** @example 75201 */
            zip?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_drivers_dto.ErrorResponse": {
            error?: components["schemas"]["github_com_devline_onebook-eld_internal_httpx_dto.ErrorBody"];
        };
        "github_com_devline_onebook-eld_internal_domain_drivers_dto.Meta": {
            /** @example 1 */
            page?: number;
            /** @example 25 */
            per_page?: number;
            /** @example 123 */
            total?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_drivers_dto.ResetPasswordEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.ResetPasswordResult"];
        };
        "github_com_devline_onebook-eld_internal_domain_drivers_dto.ResetPasswordResult": {
            /**
             * @example email
             * @enum {string}
             */
            channel?: "email" | "sms";
            /** @example 7c3b6d3e-9a1f-4a2a-8f0c-2c1d4e5f6a7b */
            driver_id?: string;
            /**
             * Format: date-time
             * @example 2026-09-09T18:22:00Z
             */
            expires_at?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_drivers_dto.StatusChange": {
            /** @example Left the company */
            reason?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_duty_dto.Counters": {
            /** @example 180 */
            break_left_min?: number;
            /** @example 3600 */
            cycle_left_min?: number;
            /** @example 420 */
            drive_left_min?: number;
            /** @example 180 */
            driving_time_left_min?: number;
            /** @example 540 */
            shift_left_min?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_duty_dto.DayTotals": {
            /** @example 480 */
            drive_min?: number;
            /** @example 600 */
            off_min?: number;
            /** @example 360 */
            on_min?: number;
            /** @example 0 */
            sb_min?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_duty_dto.DutyStatusEvent": {
            /** @example 11111111-1111-4111-8111-111111111111 */
            client_event_id?: string;
            /**
             * @description ClockSkewSec is phone minus reference clock, in seconds.
             * @example 0
             */
            clock_skew_sec?: number;
            /** @example 4b5c6d7e-8f90-41a2-b3c4-d5e6f7a8b9c0 */
            daily_log_id?: string;
            /** @example 1042 */
            device_seq?: number;
            /** @example 1234.5 */
            engine_hours?: number;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            event_time?: string;
            /**
             * @example duty_status
             * @enum {string}
             */
            event_type?: "duty_status" | "intermediate" | "login" | "logout" | "power_on" | "power_off" | "engine_on" | "engine_off" | "malfunction" | "diagnostic" | "certification" | "yard_moves" | "personal_use";
            /** @example 12 */
            gps_accuracy_m?: number;
            /** @example 7d1e2f3a-4b5c-4d6e-8f90-1a2b3c4d5e6f */
            id?: string;
            /** @example 31.52 */
            lat?: number;
            /** @example 74.35 */
            lng?: number;
            /** @example 12 km NE of Lahore */
            location_text?: string;
            /** @example false */
            locked?: boolean;
            /** @example Pickup */
            notes?: string;
            /** @example 128430000 */
            odometer_m?: number;
            /**
             * @example auto
             * @enum {string}
             */
            origin?: "auto" | "driver" | "driver_edit" | "admin_edit" | "assigned" | "manual_no_eld";
            /**
             * Format: date-time
             * @example 2026-09-06T05:14:11Z
             */
            received_at?: string;
            /**
             * @example [
             *       "1c2d3e4f-5a6b-4c7d-8e9f-0a1b2c3d4e5f"
             *     ]
             */
            shipping_doc_ids?: string[];
            /**
             * @example none
             * @enum {string}
             */
            special?: "none" | "pc" | "ym";
            /**
             * @example ON
             * @enum {string}
             */
            status?: "OFF" | "SB" | "DR" | "ON";
            /**
             * @description SupersededBy points at the event that won conflict rule 1; a superseded
             *     event stays in the log and never disappears.
             * @example 8a9b0c1d-2e3f-4a5b-8c6d-7e8f9a0b1c2d
             */
            superseded_by?: string;
            /**
             * @description TimeSource is the clock the event_time came from (Q-B1.2).
             * @example eld_rtc
             * @enum {string}
             */
            time_source?: "eld_rtc" | "server" | "phone";
            /**
             * @description TimeUnverified marks an event stamped from the phone only; the admin log
             *     shows it with a yellow marker (Q7.1).
             * @example false
             */
            time_unverified?: boolean;
            /**
             * @example [
             *       "9f8e7d6c-5b4a-4392-8281-706f5e4d3c2b"
             *     ]
             */
            trailer_ids?: string[];
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            unit_id?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_duty_dto.DutyStatusEventListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_duty_dto.DutyStatusEvent"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_duty_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_duty_dto.ErrorResponse": {
            error?: components["schemas"]["github_com_devline_onebook-eld_internal_httpx_dto.ErrorBody"];
        };
        "github_com_devline_onebook-eld_internal_domain_duty_dto.HosSummary": {
            counters?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_duty_dto.Counters"];
            /**
             * Format: date
             * @description Date is the log day in the home terminal timezone (Q10.2).
             * @example 2026-09-06
             */
            date?: string;
            /** @example 3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b */
            driver_id?: string;
            /**
             * Format: date-time
             * @description EvaluatedAt is the instant the counters describe: `now` for today, the
             *     end of the log day for a past date.
             * @example 2026-09-06T18:00:00Z
             */
            evaluated_at?: string;
            /**
             * @description PolicyVersionID is the hos_policy_versions row in force on that day
             *     (Q10.1); null means the built-in FMCSA 70/8 defaults were used.
             * @example 2f3a4b5c-6d7e-4f80-9a1b-2c3d4e5f6a7b
             */
            policy_version_id?: string;
            recap?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_duty_dto.RecapDay"][];
            /**
             * @description Timezone is the home terminal timezone the day boundary was taken in.
             * @example America/Chicago
             */
            timezone?: string;
            totals?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_duty_dto.DayTotals"];
            violations?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_duty_dto.Violation"][];
        };
        "github_com_devline_onebook-eld_internal_domain_duty_dto.HosSummaryEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_duty_dto.HosSummary"];
        };
        "github_com_devline_onebook-eld_internal_domain_duty_dto.Meta": {
            /** @example 1 */
            page?: number;
            /** @example 25 */
            per_page?: number;
            /** @example 123 */
            total?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_duty_dto.RecapDay": {
            /** @example 3360 */
            available_min?: number;
            /**
             * Format: date
             * @example 2026-09-06
             */
            date?: string;
            /** @example 120 */
            gained_next_min?: number;
            /** @example 840 */
            on_duty_min?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_duty_dto.Violation": {
            /**
             * Format: date-time
             * @example 2026-09-06T13:00:00Z
             */
            at?: string;
            /**
             * @example warning
             * @enum {string}
             */
            severity?: "warning" | "violation";
            /**
             * @example break_required
             * @enum {string}
             */
            type?: "drive_limit" | "shift_limit" | "break_required" | "cycle_limit" | "form_manner_trailer" | "form_manner_doc";
        };
        "github_com_devline_onebook-eld_internal_domain_dvir_dto.Defect": {
            /**
             * @example truck
             * @enum {string}
             */
            category?: "truck" | "trailer";
            /** @example 7f2c1b3d-4e5a-4b6c-8d9e-0f1a2b3c4d5e */
            defect_type_id?: string;
            /** @example true */
            is_critical?: boolean;
            /** @example Tires */
            name?: string;
            /** @example Left front tyre below tread limit */
            note?: string;
            /**
             * @example [
             *       "c1/dvir_photo/2026/09/06/abc.jpg"
             *     ]
             */
            photo_keys?: string[];
        };
        "github_com_devline_onebook-eld_internal_domain_dvir_dto.DefectInput": {
            /** @example 7f2c1b3d-4e5a-4b6c-8d9e-0f1a2b3c4d5e */
            defect_type_id: string;
            /** @example Left front tyre below tread limit */
            note?: string;
            /**
             * @description PhotoKeys are object storage keys produced by POST /files/presign
             *     (kind `dvir_photo`). At most five per defect (Q27.1).
             * @example [
             *       "c1/dvir_photo/2026/09/06/abc.jpg"
             *     ]
             */
            photo_keys?: string[];
        };
        "github_com_devline_onebook-eld_internal_domain_dvir_dto.DefectType": {
            /**
             * @example truck
             * @enum {string}
             */
            category?: "truck" | "trailer";
            /**
             * Format: date-time
             * @example 2026-01-01T00:00:00Z
             */
            created_at?: string;
            /** @example 7f2c1b3d-4e5a-4b6c-8d9e-0f1a2b3c4d5e */
            id?: string;
            /** @example true */
            is_active?: boolean;
            /** @example true */
            is_critical?: boolean;
            /**
             * @description IsSystem marks a default catalogue row (company_id IS NULL); it is
             *     readable by every tenant but only editable as a company copy.
             * @example true
             */
            is_system?: boolean;
            /** @example Brakes (Service) */
            name?: string;
            /** @example 8 */
            sort_order?: number;
            /**
             * Format: date-time
             * @example 2026-01-01T00:00:00Z
             */
            updated_at?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_dvir_dto.DefectTypeCreate": {
            /**
             * @example truck
             * @enum {string}
             */
            category: "truck" | "trailer";
            /** @example true */
            is_active?: boolean;
            /** @example true */
            is_critical?: boolean;
            /** @example Brakes (Service) */
            name: string;
            /** @example 8 */
            sort_order?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_dvir_dto.DefectTypeEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.DefectType"];
        };
        "github_com_devline_onebook-eld_internal_domain_dvir_dto.DefectTypeListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.DefectType"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_dvir_dto.DefectTypeUpdate": {
            /**
             * @example truck
             * @enum {string}
             */
            category?: "truck" | "trailer";
            /** @example false */
            is_active?: boolean;
            /** @example true */
            is_critical?: boolean;
            /** @example Brakes (Service) */
            name?: string;
            /** @example 8 */
            sort_order?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_dvir_dto.DriverBrief": {
            /** @example John */
            first_name?: string;
            /** @example 3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b */
            id?: string;
            /** @example Doe */
            last_name?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_dvir_dto.DvirCertify": {
            /** @example c1/signature/2026/09/07/sig.png */
            signature_key: string;
        };
        "github_com_devline_onebook-eld_internal_domain_dvir_dto.DvirCreate": {
            /** @description Defects is empty for a clean inspection (`submitted_no_defects`). */
            defects?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.DefectInput"][];
            /**
             * @description DriverSignatureKey is the storage key of the driver signature image.
             * @example c1/signature/2026/09/06/sig.png
             */
            driver_signature_key: string;
            /**
             * @description Notes is the free text remark of the inspection.
             * @example Checked at the Dallas yard
             */
            notes?: string;
            /**
             * @description TrailerIDs are the trailers inspected together with the unit.
             * @example [
             *       "9b8a7c6d-5e4f-4a3b-8c2d-1e0f9a8b7c6d"
             *     ]
             */
            trailer_ids?: string[];
            /**
             * @description Type is the pre/post trip toggle of the mobile form.
             * @example pre_trip
             * @enum {string}
             */
            type: "pre_trip" | "post_trip";
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            unit_id: string;
        };
        "github_com_devline_onebook-eld_internal_domain_dvir_dto.DvirRepair": {
            /** @example 420.5 */
            cost?: number;
            /**
             * @description InvoiceKey is the optional repair invoice (kind `invoice`).
             * @example c1/invoice/2026/09/06/inv.pdf
             */
            invoice_key?: string;
            /**
             * @description InvoiceNo, Vendor and Cost are optional bookkeeping of the repair.
             * @example INV-10233
             */
            invoice_no?: string;
            /** @example Replaced left front tyre */
            mechanic_note: string;
            /** @example c1/signature/2026/09/06/mech.png */
            mechanic_signature_key: string;
            /** @example Dallas Truck Service */
            vendor?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_dvir_dto.DvirReport": {
            /** @example c1/signature/2026/09/07/sig.png */
            certification_signature_key?: string;
            /**
             * Format: date-time
             * @example 2026-09-07T06:10:00Z
             */
            certified_at?: string;
            /** @example 3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b */
            certified_by_driver_id?: string;
            /**
             * Format: date-time
             * @example 2026-09-14T00:00:00Z
             */
            closed_at?: string;
            /** @example no follow-up DVIR within 7 days */
            closed_reason?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            created_at?: string;
            defects?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.Defect"][];
            driver?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.DriverBrief"];
            /** @example c1/signature/2026/09/06/sig.png */
            driver_signature_key?: string;
            /** @example 1234.5 */
            engine_hours?: number;
            /**
             * @description HasCriticalDefect is true when at least one defect is `is_critical`.
             * @example true
             */
            has_critical_defect?: boolean;
            /** @example 1a2b3c4d-5e6f-4a7b-8c9d-0e1f2a3b4c5d */
            id?: string;
            /**
             * @description Kind is the derived mobile label of TZ §7.3.
             * @example defects_not_fixed
             * @enum {string}
             */
            kind?: "no_defects" | "defects_not_fixed" | "defects_fixed" | "defects_uncertified";
            /** @example 31.52 */
            lat?: number;
            /** @example 74.35 */
            lng?: number;
            /** @example 3 mi NE of Dallas, TX */
            location_text?: string;
            /** @example 4c5d6e7f-8a9b-4c0d-9e1f-2a3b4c5d6e7f */
            mechanic_id?: string;
            /** @example Replaced left front tyre */
            mechanic_note?: string;
            /** @example c1/signature/2026/09/06/mech.png */
            mechanic_signature_key?: string;
            /** @example 128430000 */
            odometer_m?: number;
            /**
             * @description OutOfService mirrors units.out_of_service after the Q27.2 evaluation.
             * @example false
             */
            out_of_service?: boolean;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            performed_at?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T15:04:05Z
             */
            repaired_at?: string;
            /**
             * @example app
             * @enum {string}
             */
            source?: "app" | "paper_import";
            /**
             * @example submitted_defects_found
             * @enum {string}
             */
            status?: "draft" | "submitted_no_defects" | "submitted_defects_found" | "repaired" | "certified" | "closed_no_certification";
            /**
             * @example [
             *       "9b8a7c6d-5e4f-4a3b-8c2d-1e0f9a8b7c6d"
             *     ]
             */
            trailer_ids?: string[];
            /**
             * @example pre_trip
             * @enum {string}
             */
            type?: "pre_trip" | "post_trip";
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            unit_id?: string;
            /** @example 1021 */
            unit_number?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            updated_at?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_dvir_dto.DvirReportEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.DvirReport"];
        };
        "github_com_devline_onebook-eld_internal_domain_dvir_dto.DvirReportListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.DvirReport"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_dvir_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_dvir_dto.ErrorResponse": {
            error?: components["schemas"]["github_com_devline_onebook-eld_internal_httpx_dto.ErrorBody"];
        };
        "github_com_devline_onebook-eld_internal_domain_dvir_dto.Meta": {
            /** @example 1 */
            page?: number;
            /** @example 25 */
            per_page?: number;
            /** @example 123 */
            total?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_files_dto.ErrorResponse": {
            error?: components["schemas"]["github_com_devline_onebook-eld_internal_httpx_dto.ErrorBody"];
        };
        "github_com_devline_onebook-eld_internal_domain_files_dto.ImportResult": {
            errors?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ImportRowError"][];
            /** @example 120 */
            imported?: number;
            /** @example 120 */
            total?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_files_dto.ImportResultEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.ImportResult"];
        };
        "github_com_devline_onebook-eld_internal_domain_files_dto.ImportRowError": {
            /** @example username */
            field?: string;
            /** @example must be 4-32 characters of [a-z0-9._] */
            message?: string;
            /** @example 7 */
            row?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_files_dto.PresignEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_files_dto.PresignResponse"];
        };
        "github_com_devline_onebook-eld_internal_domain_files_dto.PresignRequest": {
            /** @example image/jpeg */
            content_type: string;
            /**
             * @description Filename is optional and only contributes a sanitised file extension.
             * @example pre-trip-front.jpg
             */
            filename?: string;
            /**
             * @example dvir_photo
             * @enum {string}
             */
            kind: "dvir_photo" | "invoice" | "signature" | "logo" | "chat" | "import";
            /**
             * @description SizeBytes is the size the client is about to upload; it is checked
             *     against the per-kind ceiling before a URL is issued and is then signed
             *     into the URL as Content-Length, so the PUT must match it exactly.
             * @example 1048576
             */
            size_bytes: number;
        };
        "github_com_devline_onebook-eld_internal_domain_files_dto.PresignResponse": {
            /**
             * Format: date-time
             * @example 2026-09-06T12:15:00Z
             */
            expires_at?: string;
            /**
             * @example {
             *       "Content-Type": "image/jpeg"
             *     }
             */
            headers?: {
                [key: string]: string;
            };
            /** @example 1f2e3d4c-5b6a-4978-8habc/dvir_photo/2026/09/8c7b6a59-4837-4261-95f4-e3d2c1b0a9f8.jpg */
            key?: string;
            /** @example 5242880 */
            max_bytes?: number;
            /**
             * @description Method is always PUT.
             * @example PUT
             */
            method?: string;
            /** @example https://s3.example.com/onebook-eld/1f.../dvir_photo/2026/09/8c7....jpg?X-Amz-Signature=... */
            upload_url?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.CatalogCreate": {
            /** @example Reefer */
            notes?: string;
            /** @example TR-4410 */
            number: string;
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.CatalogUpdate": {
            /** @example Reefer */
            notes?: string;
            /** @example TR-4410 */
            number?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.EldDevice": {
            /**
             * @example bluetooth
             * @enum {string}
             */
            connection_type?: "bluetooth" | "wifi" | "cellular" | "usb";
            /**
             * Format: date-time
             * @example 2026-01-14T09:00:00Z
             */
            created_at?: string;
            /** @example 4.12.1 */
            firmware?: string;
            /** @example 9c3f2f1e-2b4a-4f7d-9a1e-0f2b3c4d5e6f */
            id?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            last_seen_at?: string;
            /**
             * @description MalfunctionCodes are the raised FMCSA Appendix A letters (P/E/T/L/R/S/O).
             * @example [
             *       "E",
             *       "L"
             *     ]
             */
            malfunction_codes?: string[];
            /** @example GO9 */
            model?: string;
            /** @example Spare unit */
            notes?: string;
            /** @example ELD-000123 */
            serial?: string;
            /** @example true */
            sim_present?: boolean;
            /**
             * @example active
             * @enum {string}
             */
            status?: "active" | "inactive" | "malfunction";
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            unit_id?: string;
            /** @example 1021 */
            unit_number?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            updated_at?: string;
            /** @example Geotab */
            vendor?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.EldDeviceAssignUnit": {
            /**
             * @description UnitID is null to detach the device from its current unit.
             * @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f
             */
            unit_id?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.EldDeviceCreate": {
            /**
             * @example bluetooth
             * @enum {string}
             */
            connection_type?: "bluetooth" | "wifi" | "cellular" | "usb";
            /** @example 4.12.1 */
            firmware?: string;
            /** @example GO9 */
            model?: string;
            /** @example Spare unit */
            notes?: string;
            /** @example ELD-000123 */
            serial: string;
            /** @example true */
            sim_present?: boolean;
            /**
             * @example active
             * @enum {string}
             */
            status?: "active" | "inactive" | "malfunction";
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            unit_id?: string;
            /** @example Geotab */
            vendor: string;
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.EldDeviceEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.EldDevice"];
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.EldDeviceListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.EldDevice"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.EldDeviceUpdate": {
            /**
             * @example bluetooth
             * @enum {string}
             */
            connection_type?: "bluetooth" | "wifi" | "cellular" | "usb";
            /** @example 4.12.1 */
            firmware?: string;
            /** @example GO9 */
            model?: string;
            /** @example Spare unit */
            notes?: string;
            /** @example ELD-000123 */
            serial?: string;
            /** @example true */
            sim_present?: boolean;
            /**
             * @example active
             * @enum {string}
             */
            status?: "active" | "inactive" | "malfunction";
            /** @example Geotab */
            vendor?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.ErrorResponse": {
            error?: components["schemas"]["github_com_devline_onebook-eld_internal_httpx_dto.ErrorBody"];
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.MalfunctionCode": {
            /**
             * @example E
             * @enum {string}
             */
            code?: "P" | "E" | "T" | "L" | "R" | "S" | "O";
            /** @example engine synchronization */
            description?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.Meta": {
            /** @example 1 */
            page?: number;
            /** @example 25 */
            per_page?: number;
            /** @example 123 */
            total?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.ShippingDocument": {
            /**
             * Format: date-time
             * @example 2026-01-14T09:00:00Z
             */
            created_at?: string;
            /** @example 8e9f0a1b-2c3d-4e5f-8a9b-0c1d2e3f4a5b */
            id?: string;
            /** @example Cold chain */
            notes?: string;
            /** @example BOL-99127 */
            number?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            updated_at?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.ShippingDocumentEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ShippingDocument"];
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.ShippingDocumentListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.ShippingDocument"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.Trailer": {
            /**
             * Format: date-time
             * @example 2026-01-14T09:00:00Z
             */
            created_at?: string;
            /** @example 5b6c7d8e-9f0a-4b1c-8d2e-3f4a5b6c7d8e */
            id?: string;
            /** @example Reefer */
            notes?: string;
            /** @example TR-4410 */
            number?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            updated_at?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.TrailerEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.Trailer"];
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.TrailerListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.Trailer"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.Unit": {
            /**
             * Format: date-time
             * @example 2026-01-14T09:00:00Z
             */
            activated_on?: string;
            /** @example 2b7c4d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f */
            branch_id?: string;
            /** @example Dallas terminal */
            branch_name?: string;
            /**
             * Format: date-time
             * @example 2026-01-14T09:00:00Z
             */
            created_at?: string;
            /**
             * @description EldDeviceID is the ELD currently wired to this unit, null when none.
             * @example 9c3f2f1e-2b4a-4f7d-9a1e-0f2b3c4d5e6f
             */
            eld_device_id?: string;
            /** @example ELD-000123 */
            eld_device_serial?: string;
            /**
             * @example diesel
             * @enum {string}
             */
            fuel_type?: "diesel" | "petrol" | "cng" | "lpg" | "electric" | "hybrid";
            /** @example class_8 */
            gvwr_class?: string;
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            id?: string;
            /** @example AA123BB */
            license_plate?: string;
            /** @example Freightliner */
            make?: string;
            /** @example Cascadia */
            model?: string;
            /** @example Winter tyres fitted */
            notes?: string;
            /**
             * @description OdometerM is the last telemetry odometer reading in metres, null when the
             *     unit has never reported. The backend never converts units.
             * @example 128430000
             */
            odometer_m?: number;
            /** @example false */
            out_of_service?: boolean;
            /** @example TX */
            plate_region?: string;
            /** @example true */
            sleeper_berth?: boolean;
            /**
             * @example active
             * @enum {string}
             */
            status?: "active" | "inactive";
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            telemetry_at?: string;
            /** @example 1021 */
            unit_number?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            updated_at?: string;
            /** @example 1FUJGLDR9CLBP8834 */
            vin?: string;
            /** @example 2021 */
            year?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitAssignDriver": {
            /** @example 4a2b3c4d-5e6f-4a1b-8c2d-3e4f5a6b7c8d */
            driver_id: string;
            /**
             * @example primary
             * @enum {string}
             */
            role: "primary" | "co";
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitAssignment": {
            /**
             * Format: date-time
             * @example 2026-09-01T06:00:00Z
             */
            assigned_at?: string;
            /** @example 4a2b3c4d-5e6f-4a1b-8c2d-3e4f5a6b7c8d */
            driver_id?: string;
            /** @example John Doe */
            driver_name?: string;
            /** @example 1c2d3e4f-5a6b-4c7d-8e9f-0a1b2c3d4e5f */
            id?: string;
            /**
             * @example primary
             * @enum {string}
             */
            role?: "primary" | "co";
            /**
             * Format: date-time
             * @example 2026-09-05T18:30:00Z
             */
            unassigned_at?: string;
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            unit_id?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitAssignmentEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitAssignment"];
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitCreate": {
            /** @example 2b7c4d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f */
            branch_id?: string;
            /** @example 9c3f2f1e-2b4a-4f7d-9a1e-0f2b3c4d5e6f */
            eld_device_id?: string;
            /**
             * @example diesel
             * @enum {string}
             */
            fuel_type: "diesel" | "petrol" | "cng" | "lpg" | "electric" | "hybrid";
            /** @example class_8 */
            gvwr_class?: string;
            /** @example AA123BB */
            license_plate: string;
            /** @example Freightliner */
            make: string;
            /** @example Cascadia */
            model: string;
            /** @example Winter tyres fitted */
            notes?: string;
            /** @example TX */
            plate_region?: string;
            /** @example true */
            sleeper_berth?: boolean;
            /** @example 1021 */
            unit_number: string;
            /** @example 1FUJGLDR9CLBP8834 */
            vin?: string;
            /** @example 2021 */
            year?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitDiagnostics": {
            /**
             * @description ConnectionState is the administrator facing device state.
             * @example online
             * @enum {string}
             */
            connection_state?: "online" | "offline" | "disconnected" | "malfunction" | "no_device";
            /**
             * @example bluetooth
             * @enum {string}
             */
            connection_type?: "bluetooth" | "wifi" | "cellular" | "usb";
            /** @example 4.12.1 */
            device_firmware?: string;
            /** @example 9c3f2f1e-2b4a-4f7d-9a1e-0f2b3c4d5e6f */
            device_id?: string;
            /** @example GO9 */
            device_model?: string;
            /** @example ELD-000123 */
            device_serial?: string;
            /**
             * @example active
             * @enum {string}
             */
            device_status?: "active" | "inactive" | "malfunction";
            /** @example Geotab */
            device_vendor?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            last_seen_at?: string;
            /**
             * @description MalfunctionCodes are FMCSA Appendix A letters: P power, E engine sync,
             *     T timing, L positioning, R data recording, S data transfer, O other.
             */
            malfunction_codes?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.MalfunctionCode"][];
            /** @example true */
            sim_present?: boolean;
            telemetry?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitTelemetry"];
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            telemetry_at?: string;
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            unit_id?: string;
            /** @example 1021 */
            unit_number?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitDiagnosticsEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitDiagnostics"];
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.Unit"];
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitHistoryEntry": {
            /**
             * @example update
             * @enum {string}
             */
            action?: "create" | "update" | "delete" | "restore" | "assign";
            /** @example 7c9f2f1e-2b4a-4f7d-9a1e-0f2b3c4d5e6f */
            actor_id?: string;
            /** @example Jane Admin */
            actor_name?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            at?: string;
            /** @example status */
            field?: string;
            /** @example 1c2d3e4f-5a6b-4c7d-8e9f-0a1b2c3d4e5f */
            id?: string;
            /**
             * @description Kind separates the two sources merged into one timeline.
             * @example audit
             * @enum {string}
             */
            kind?: "audit" | "assignment";
            /** @example "inactive" */
            new_value?: string;
            /** @example "active" */
            old_value?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitHistoryEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitHistoryEntry"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.Unit"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitTelemetry": {
            /** @example 96.5 */
            battery_pct?: number;
            /** @example 13.8 */
            battery_voltage_v?: number;
            /** @example 91.2 */
            coolant_level_pct?: number;
            /** @example 88.4 */
            coolant_temp_c?: number;
            /** @example 14320.75 */
            engine_hours?: number;
            /** @example 62.5 */
            fuel_pct?: number;
            /** @example 128430000 */
            odometer_m?: number;
            /** @example 78 */
            oil_level_pct?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.UnitUpdate": {
            /** @example 2b7c4d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f */
            branch_id?: string;
            /**
             * @example diesel
             * @enum {string}
             */
            fuel_type?: "diesel" | "petrol" | "cng" | "lpg" | "electric" | "hybrid";
            /** @example class_8 */
            gvwr_class?: string;
            /** @example AA123BB */
            license_plate?: string;
            /** @example Freightliner */
            make?: string;
            /** @example Cascadia */
            model?: string;
            /** @example Winter tyres fitted */
            notes?: string;
            /** @example false */
            out_of_service?: boolean;
            /** @example TX */
            plate_region?: string;
            /** @example true */
            sleeper_berth?: boolean;
            /** @example 1021 */
            unit_number?: string;
            /** @example 1FUJGLDR9CLBP8834 */
            vin?: string;
            /** @example 2021 */
            year?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.CertifyRequest": {
            /** @example pixel-8-a1b2 */
            device_id?: string;
            /** @example 5c6d7e8f-9a0b-4c1d-8e2f-3a4b5c6d7e8f */
            signature_id?: string;
            /** @example companies/6f1a/signatures/2026/09/sig.png */
            signature_key?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.DailyLogDetail": {
            /**
             * @description CertificationStatus is the Q19 tri-state.
             * @example uncertified
             * @enum {string}
             */
            certification_status?: "uncertified" | "certified" | "needs_recertify";
            /**
             * @description CoDriverName is the second seat of the day, null when driving alone.
             * @example Bekzod Rasulov
             */
            co_driver_name?: string;
            /** @example 412000 */
            distance_m?: number;
            /** @example 3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b */
            driver_id?: string;
            /**
             * @description DriverName is "First Last" of the log owner.
             * @example Ali Karimov
             */
            driver_name?: string;
            events?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.LogEvent"][];
            form?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.LogForm"];
            /** @example 4b5c6d7e-8f90-41a2-b3c4-d5e6f7a8b9c0 */
            id?: string;
            /**
             * Format: date
             * @description LogDate is the home terminal calendar day (Q10.2).
             * @example 2026-09-06
             */
            log_date?: string;
            /**
             * @description Ready is false while the day still misses its signature (Q25).
             * @example false
             */
            ready?: boolean;
            /**
             * Format: date-time
             * @example 2026-09-06T23:50:00Z
             */
            signed_at?: string;
            /** @example America/Chicago */
            timezone?: string;
            totals?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.DayTotals"];
            /**
             * @example [
             *       "6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"
             *     ]
             */
            unit_ids?: string[];
            /**
             * Format: date-time
             * @example 2026-09-06T23:50:01Z
             */
            updated_at?: string;
            violations?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.Violation"][];
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.DailyLogEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.DailyLogDetail"];
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.DailyLogListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.DailyLogSummary"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.DailyLogSummary": {
            /**
             * @description CertificationStatus is the Q19 tri-state.
             * @example uncertified
             * @enum {string}
             */
            certification_status?: "uncertified" | "certified" | "needs_recertify";
            /**
             * @description CoDriverName is the second seat of the day, null when driving alone.
             * @example Bekzod Rasulov
             */
            co_driver_name?: string;
            /** @example 412000 */
            distance_m?: number;
            /** @example 3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b */
            driver_id?: string;
            /**
             * @description DriverName is "First Last" of the log owner.
             * @example Ali Karimov
             */
            driver_name?: string;
            /** @example 4b5c6d7e-8f90-41a2-b3c4-d5e6f7a8b9c0 */
            id?: string;
            /**
             * Format: date
             * @description LogDate is the home terminal calendar day (Q10.2).
             * @example 2026-09-06
             */
            log_date?: string;
            /**
             * @description Ready is false while the day still misses its signature (Q25).
             * @example false
             */
            ready?: boolean;
            /**
             * Format: date-time
             * @example 2026-09-06T23:50:00Z
             */
            signed_at?: string;
            /** @example America/Chicago */
            timezone?: string;
            totals?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.DayTotals"];
            /**
             * @example [
             *       "6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"
             *     ]
             */
            unit_ids?: string[];
            /**
             * Format: date-time
             * @example 2026-09-06T23:50:01Z
             */
            updated_at?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.DayTotals": {
            /** @example 480 */
            drive_min?: number;
            /** @example 600 */
            off_min?: number;
            /** @example 360 */
            on_min?: number;
            /** @example 0 */
            sb_min?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.ErrorResponse": {
            error?: components["schemas"]["github_com_devline_onebook-eld_internal_httpx_dto.ErrorBody"];
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.InspectionEmail": {
            /** @example Roadside check, I-35 mile 220 */
            comment?: string;
            /**
             * Format: date
             * @description Date anchors the 7 days + today window; defaults to today.
             * @example 2026-09-06
             */
            date?: string;
            /**
             * @description DriverID is required for an admin caller; a driver always sends its own.
             * @example 3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b
             */
            driver_id?: string;
            /** @example inspector@dot.gov */
            email: string;
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.InspectionReport": {
            /** @example ONEBOOK Logistics */
            carrier_name?: string;
            days?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.DailyLogDetail"][];
            /** @example 3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b */
            driver_id?: string;
            /** @example Ali Karimov */
            driver_name?: string;
            /**
             * Format: date
             * @example 2026-08-30
             */
            from?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T18:00:00Z
             */
            generated_at?: string;
            /** @example 1200 Industrial Rd, Dallas, TX */
            home_terminal_address?: string;
            /**
             * @description RegulationProfile decides the transfer format (Q56).
             * @example generic
             * @enum {string}
             */
            regulation_profile?: "us_fmcsa" | "generic" | "canada" | "texas" | "california" | "alaska" | "hawaii";
            /** @example America/Chicago */
            timezone?: string;
            /**
             * Format: date
             * @example 2026-09-06
             */
            to?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.InspectionReportEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.InspectionReport"];
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.InspectionSession": {
            /** @example 3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b */
            driver_id?: string;
            /** @example Ali Karimov */
            driver_name?: string;
            /**
             * Format: date-time
             * @description ExpiresAt bounds the inspector's read window.
             * @example 2026-09-06T20:00:00Z
             */
            expires_at?: string;
            /** @example eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... */
            token?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.InspectionSessionEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.InspectionSession"];
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.InspectionTransfer": {
            /** @example Roadside check, I-35 mile 220 */
            comment?: string;
            /**
             * Format: date
             * @example 2026-09-06
             */
            date?: string;
            /** @example 3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b */
            driver_id?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.InspectionTransferEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.InspectionTransferResult"];
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.InspectionTransferResult": {
            /**
             * @description FileKey is the object storage key of the produced archive.
             * @example companies/6f1a/inspection/2026/09/eld-output.zip
             */
            file_key?: string;
            /**
             * @example csv_pdf_zip
             * @enum {string}
             */
            format?: "csv_pdf_zip" | "fmcsa_eld_output";
            /**
             * Format: date-time
             * @example 2026-09-06T18:00:00Z
             */
            generated_at?: string;
            /**
             * @description RegulationProfile is the company profile that selected the format.
             * @example generic
             * @enum {string}
             */
            regulation_profile?: "us_fmcsa" | "generic" | "canada" | "texas" | "california" | "alaska" | "hawaii";
            /**
             * @description SizeBytes is the archive size.
             * @example 48213
             */
            size_bytes?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.LogEditChange": {
            /**
             * Format: date-time
             * @example 2026-09-06T13:00:00Z
             */
            from: string;
            /** @example Loading at the dock, forgot to switch */
            note: string;
            /**
             * @example none
             * @enum {string}
             */
            special?: "none" | "pc" | "ym";
            /**
             * @example ON
             * @enum {string}
             */
            status: "OFF" | "SB" | "DR" | "ON";
            /**
             * Format: date-time
             * @example 2026-09-06T15:00:00Z
             */
            to: string;
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.LogEditReject": {
            /** @example That block was my co-driver */
            reason: string;
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.LogEditRequest": {
            changes?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.LogEditChange"][];
            /**
             * Format: date-time
             * @example 2026-09-06T18:00:00Z
             */
            created_at?: string;
            /** @example 4b5c6d7e-8f90-41a2-b3c4-d5e6f7a8b9c0 */
            daily_log_id?: string;
            /** @example 3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b */
            driver_id?: string;
            /** @example Ali Karimov */
            driver_name?: string;
            /**
             * @description DriverNote carries the rejection reason once the driver answered.
             * @example That was my co-driver, not me
             */
            driver_note?: string;
            /** @example 7b8c9d0e-1f2a-4b3c-8d4e-5f6a7b8c9d0e */
            id?: string;
            /**
             * Format: date
             * @example 2026-09-06
             */
            log_date?: string;
            /** @example 1a2b3c4d-5e6f-4a7b-8c9d-0e1f2a3b4c5d */
            requested_by?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T19:04:00Z
             */
            resolved_at?: string;
            /**
             * @description Source separates an admin proposal from an unidentified driving
             *     assignment awaiting the same driver approval (§10.4).
             * @example admin_edit
             * @enum {string}
             */
            source?: "admin_edit" | "unidentified_assign";
            /**
             * @example pending
             * @enum {string}
             */
            status?: "pending" | "approved" | "rejected";
            /** @example America/Chicago */
            timezone?: string;
            /** @example 2b3c4d5e-6f70-4819-a2b3-c4d5e6f7a8b9 */
            unidentified_event_id?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T19:04:00Z
             */
            updated_at?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.LogEditRequestCreate": {
            changes: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.LogEditChange"][];
            /** @example 4b5c6d7e-8f90-41a2-b3c4-d5e6f7a8b9c0 */
            daily_log_id: string;
            /** @example 3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b */
            driver_id: string;
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.LogEditRequestEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.LogEditRequest"];
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.LogEditRequestListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.LogEditRequest"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.LogEvent": {
            /**
             * @description Edited marks the ✎ badge: the row came from an edit (Q17.2).
             * @example false
             */
            edited?: boolean;
            /** @example 1234.5 */
            engine_hours?: number;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            event_time?: string;
            /**
             * @example duty_status
             * @enum {string}
             */
            event_type?: "duty_status" | "intermediate" | "login" | "logout" | "power_on" | "power_off" | "engine_on" | "engine_off" | "malfunction" | "diagnostic" | "certification" | "yard_moves" | "personal_use";
            /** @example 7d1e2f3a-4b5c-4d6e-8f90-1a2b3c4d5e6f */
            id?: string;
            /** @example 31.52 */
            lat?: number;
            /** @example 74.35 */
            lng?: number;
            /** @example 12 km NE of Lahore */
            location_text?: string;
            /**
             * @description Locked is true once the day has been certified (Q26.1).
             * @example false
             */
            locked?: boolean;
            /** @example Admin correction: forgot to switch to ON */
            notes?: string;
            /** @example 128430000 */
            odometer_m?: number;
            /**
             * @description Origin says who produced the row; `auto` is the ELD itself (Q13.1).
             * @example auto
             * @enum {string}
             */
            origin?: "auto" | "driver" | "driver_edit" | "admin_edit" | "assigned";
            /**
             * Format: date-time
             * @example 2026-09-06T05:14:11Z
             */
            received_at?: string;
            /**
             * @example none
             * @enum {string}
             */
            special?: "none" | "pc" | "ym";
            /**
             * @example ON
             * @enum {string}
             */
            status?: "OFF" | "SB" | "DR" | "ON";
            /**
             * @description SupersededBy points at the row that replaced this one. The original is
             *     never deleted (Q17).
             * @example 8a9b0c1d-2e3f-4a5b-8c6d-7e8f9a0b1c2d
             */
            superseded_by?: string;
            /**
             * @example eld_rtc
             * @enum {string}
             */
            time_source?: "eld_rtc" | "server" | "phone";
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            unit_id?: string;
            /** @example 1021 */
            unit_number?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.LogEventCreate": {
            /**
             * Format: date-time
             * @example 2026-09-06T13:00:00Z
             */
            from: string;
            /** @example Yard move at the terminal */
            note: string;
            /**
             * @example none
             * @enum {string}
             */
            special?: "none" | "pc" | "ym";
            /**
             * @example ON
             * @enum {string}
             */
            status: "OFF" | "SB" | "DR" | "ON";
            /**
             * Format: date-time
             * @example 2026-09-06T15:00:00Z
             */
            to: string;
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            unit_id?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.LogForm": {
            /** @example ONEBOOK Logistics */
            carrier_name?: string;
            /** @example Bekzod Rasulov */
            co_driver_name?: string;
            /** @example 412000 */
            distance_m?: number;
            /** @example Ali Karimov */
            driver_name?: string;
            /**
             * @description HomeTerminalAddress is the carrier's home terminal (Q16).
             * @example 1200 Industrial Rd, Dallas, TX
             */
            home_terminal_address?: string;
            shipping_docs?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.NumberRef"][];
            /**
             * @description SignatureKey is the object storage key of the stored signature image.
             * @example companies/6f1a/signatures/2026/09/sig.png
             */
            signature_key?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T23:50:00Z
             */
            signed_at?: string;
            /** @example pixel-8-a1b2 */
            signed_device_id?: string;
            /** @example 203.0.113.7 */
            signed_ip?: string;
            trailers?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.NumberRef"][];
            units?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.UnitRef"][];
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.MessageEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_httpx_dto.MessageResponse"];
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.Meta": {
            /** @example 1 */
            page?: number;
            /** @example 25 */
            per_page?: number;
            /** @example 123 */
            total?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.NumberRef": {
            /** @example 9f8e7d6c-5b4a-4392-8281-706f5e4d3c2b */
            id?: string;
            /** @example TR-77 */
            number?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.UncertifiedLog": {
            /**
             * @example uncertified
             * @enum {string}
             */
            certification_status?: "uncertified" | "needs_recertify";
            /** @example 4b5c6d7e-8f90-41a2-b3c4-d5e6f7a8b9c0 */
            daily_log_id?: string;
            /**
             * @description DaysOverdue counts calendar days past the 8 day certification window.
             * @example 3
             */
            days_overdue?: number;
            /** @example 3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b */
            driver_id?: string;
            /** @example Ali Karimov */
            driver_name?: string;
            /**
             * Format: date
             * @example 2026-08-20
             */
            log_date?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.UncertifiedLogListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.UncertifiedLog"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.UnidentifiedAnnotate": {
            /** @example Mechanic test drive after brake repair */
            annotation: string;
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.UnidentifiedAssign": {
            /** @example 3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b */
            driver_id: string;
            /** @example Matches your dispatch for that trip */
            note: string;
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.UnidentifiedEvent": {
            /** @example Mechanic test drive */
            annotation?: string;
            /** @example 3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b */
            assigned_driver_id?: string;
            /** @example Ali Karimov */
            assigned_driver_name?: string;
            /**
             * Format: date-time
             * @example 2026-09-05T14:41:00Z
             */
            created_at?: string;
            /** @example 18400 */
            distance_m?: number;
            /** @example 7b8c9d0e-1f2a-4b3c-8d4e-5f6a7b8c9d0e */
            edit_request_id?: string;
            /**
             * Format: date-time
             * @example 2026-09-05T14:40:00Z
             */
            end_at?: string;
            /** @example 2b3c4d5e-6f70-4819-a2b3-c4d5e6f7a8b9 */
            id?: string;
            /**
             * Format: date-time
             * @example 2026-09-05T14:00:00Z
             */
            start_at?: string;
            /**
             * @description Status is `proposed` while an admin assignment waits for the driver.
             * @example pending
             * @enum {string}
             */
            status?: "pending" | "proposed" | "assigned" | "annotated";
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            unit_id?: string;
            /** @example 1021 */
            unit_number?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.UnidentifiedEventEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.UnidentifiedEvent"];
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.UnitRef": {
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            id?: string;
            /** @example AA1234BB */
            license_plate?: string;
            /** @example 1021 */
            unit_number?: string;
            /** @example 1FUJGLDR9CSBP8834 */
            vin?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.Violation": {
            /**
             * Format: date-time
             * @example 2026-09-06T17:00:05Z
             */
            created_at?: string;
            /** @example 4b5c6d7e-8f90-41a2-b3c4-d5e6f7a8b9c0 */
            daily_log_id?: string;
            details?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.ViolationDetails"];
            /**
             * @description DriverID is null for `unidentified_driving`, which has no driver yet.
             * @example 3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b
             */
            driver_id?: string;
            /** @example Ali Karimov */
            driver_name?: string;
            /** @example 0a1b2c3d-4e5f-4a6b-8c7d-8e9f0a1b2c3d */
            id?: string;
            /**
             * Format: date
             * @example 2026-09-06
             */
            log_date?: string;
            /**
             * Format: date-time
             * @description OccurredAt is the instant the engine placed the breach.
             * @example 2026-09-06T17:00:00Z
             */
            occurred_at?: string;
            /**
             * @description PolicyVersionID is the hos_policy_versions row the day was judged under
             *     (Q10.1); null means the built-in FMCSA defaults.
             * @example 2f3a4b5c-6d7e-4f80-9a1b-2c3d4e5f6a7b
             */
            policy_version_id?: string;
            /**
             * Format: date-time
             * @description ResolvedAt closes the violation; the row itself stays forever (Q58).
             * @example 2026-09-07T06:00:00Z
             */
            resolved_at?: string;
            /** @example daily rest completed */
            resolved_reason?: string;
            /**
             * @example violation
             * @enum {string}
             */
            severity?: "warning" | "violation";
            /**
             * @description Type is the canonical HOS violation catalogue (Q57).
             * @example drive_limit
             * @enum {string}
             */
            type?: "form_manner_trailer" | "form_manner_doc" | "drive_limit" | "shift_limit" | "break_required" | "cycle_limit" | "uncertified_log" | "unidentified_driving" | "eld_malfunction" | "missing_dvir";
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            unit_id?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.ViolationDetails": {
            /**
             * @description DaysUncertified counts the uncertified days behind an `uncertified_log`.
             * @example 2
             */
            days_uncertified?: number;
            /**
             * @description LimitMin is the policy limit that was measured against, in minutes.
             * @example 660
             */
            limit_min?: number;
            /**
             * @description Note is the human readable explanation.
             * @example driving beyond the 11 hour limit
             */
            note?: string;
            /**
             * @description RemainingMin is what was left when a warning was raised.
             * @example 20
             */
            remaining_min?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.ViolationEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.Violation"];
        };
        "github_com_devline_onebook-eld_internal_domain_logs_dto.ViolationListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.Violation"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_maintenance_dto.CancelInput": {
            /** @example Unit sold */
            cancelled_reason: string;
        };
        "github_com_devline_onebook-eld_internal_domain_maintenance_dto.CompleteInput": {
            /** @example 420.5 */
            cost?: number;
            /** @example USD */
            currency?: string;
            /**
             * @description InvoiceKey is the storage key of the invoice PDF/JPG (kind `invoice`).
             * @example c1/invoice/2026/09/06/inv.pdf
             */
            invoice_key?: string;
            /** @example INV-10233 */
            invoice_no?: string;
            /** @example Oil and filter replaced */
            notes?: string;
            /**
             * Format: date-time
             * @description PerformedAt defaults to now when omitted.
             * @example 2026-09-06T15:04:05Z
             */
            performed_at?: string;
            /** @example Dallas Truck Service */
            vendor?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_maintenance_dto.ErrorResponse": {
            error?: components["schemas"]["github_com_devline_onebook-eld_internal_httpx_dto.ErrorBody"];
        };
        "github_com_devline_onebook-eld_internal_domain_maintenance_dto.Meta": {
            /** @example 1 */
            page?: number;
            /** @example 25 */
            per_page?: number;
            /** @example 123 */
            total?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_maintenance_dto.Record": {
            /** @example Unit sold */
            cancelled_reason?: string;
            /** @example 420.5 */
            cost?: number;
            /**
             * Format: date-time
             * @example 2026-09-06T15:04:05Z
             */
            created_at?: string;
            /** @example USD */
            currency?: string;
            /** @example 1234.5 */
            engine_hours?: number;
            /** @example 5a4b3c2d-1e0f-4a9b-8c7d-6e5f4a3b2c1d */
            id?: string;
            /** @example c1/invoice/2026/09/06/inv.pdf */
            invoice_key?: string;
            /** @example INV-10233 */
            invoice_no?: string;
            /** @example Oil and filter replaced */
            notes?: string;
            /** @example 128430000 */
            odometer_m?: number;
            /**
             * Format: date-time
             * @example 2026-09-06T15:04:05Z
             */
            performed_at?: string;
            /** @example 8c7b6a59-4d3e-4f2a-9b8c-7d6e5f4a3b2c */
            schedule_unit_id?: string;
            /**
             * @example completed
             * @enum {string}
             */
            status?: "completed" | "cancelled";
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            unit_id?: string;
            /** @example 1021 */
            unit_number?: string;
            /** @example Dallas Truck Service */
            vendor?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_maintenance_dto.RecordListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.Record"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_maintenance_dto.Schedule": {
            /**
             * @example notification
             * @enum {string}
             */
            alert_type?: "notification" | "email" | "sms" | "none";
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            created_at?: string;
            /**
             * @example [
             *       "push",
             *       "email"
             *     ]
             */
            delivery_methods?: string[];
            /** @example 2f3e4d5c-6b7a-4980-9a1b-2c3d4e5f6a7b */
            id?: string;
            /**
             * @example km
             * @enum {string}
             */
            interval_unit?: "km" | "mi" | "days" | "engine_hours";
            /** @example 25000 */
            interval_value?: number;
            /** @example Engine oil change */
            name?: string;
            /** @example Use synthetic oil only */
            notes?: string;
            /** @example true */
            notify_co_driver?: boolean;
            /** @example 1000 */
            reminder_before_value?: number;
            /**
             * @example active
             * @enum {string}
             */
            status?: "active" | "inactive";
            /** @example oil_change */
            type?: string;
            /**
             * @description UnitCount is the number of units currently attached.
             * @example 12
             */
            unit_count?: number;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            updated_at?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_maintenance_dto.ScheduleCreate": {
            /**
             * @example notification
             * @enum {string}
             */
            alert_type?: "notification" | "email" | "sms" | "none";
            /**
             * @description DeliveryMethods are the channels the reminder is fanned out to.
             * @example [
             *       "push",
             *       "email"
             *     ]
             */
            delivery_methods?: string[];
            /**
             * @example km
             * @enum {string}
             */
            interval_unit: "km" | "mi" | "days" | "engine_hours";
            /** @example 25000 */
            interval_value: number;
            /** @example Engine oil change */
            name: string;
            /** @example Use synthetic oil only */
            notes?: string;
            /**
             * @description NotifyCoDriver also reminds the co-driver of the unit (Q38).
             * @example true
             */
            notify_co_driver?: boolean;
            /**
             * @description ReminderBeforeValue fires the Q37 reminder this far ahead of the due
             *     point, in the same unit as the interval.
             * @example 1000
             */
            reminder_before_value?: number;
            /**
             * @example active
             * @enum {string}
             */
            status?: "active" | "inactive";
            /**
             * @description Type is the free form service category shown in the UI.
             * @example oil_change
             */
            type?: string;
            /** @description Units attaches the fleet covered by this schedule. */
            units?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ScheduleUnitInput"][];
        };
        "github_com_devline_onebook-eld_internal_domain_maintenance_dto.ScheduleEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.Schedule"];
        };
        "github_com_devline_onebook-eld_internal_domain_maintenance_dto.ScheduleListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.Schedule"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_maintenance_dto.ScheduleUnit": {
            /** @example Unit sold */
            cancelled_reason?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            created_at?: string;
            /**
             * @description CurrentValue is the live reading: telemetry for km/mi/engine hours,
             *     elapsed days for a day interval. Null when the unit never reported.
             * @example 127100
             */
            current_value?: number;
            /** @example 1234.5 */
            engine_hours?: number;
            /** @example 8c7b6a59-4d3e-4f2a-9b8c-7d6e5f4a3b2c */
            id?: string;
            /**
             * @example km
             * @enum {string}
             */
            interval_unit?: "km" | "mi" | "days" | "engine_hours";
            /** @example 25000 */
            interval_value?: number;
            /**
             * Format: date-time
             * @example 2026-05-01T00:00:00Z
             */
            last_service_at?: string;
            /**
             * @description LastServiceValue is the reading at the last completed service.
             * @example 103430
             */
            last_service_value?: number;
            /**
             * Format: date-time
             * @example 2026-11-01T00:00:00Z
             */
            next_due_at?: string;
            /**
             * @description NextDueValue is last_service_value + interval_value.
             * @example 128430
             */
            next_due_value?: number;
            /**
             * @description OdometerM is the raw telemetry odometer in metres, for clients that do
             *     their own unit conversion.
             * @example 127100000
             */
            odometer_m?: number;
            /**
             * @description Overdue is Remaining < 0 (Q34 — shown red in the UI).
             * @example false
             */
            overdue?: boolean;
            /**
             * @description Remaining is next_due_value - current_value; negative means overdue.
             * @example 1330
             */
            remaining?: number;
            /**
             * @description ReminderDue is true once Remaining fell to reminder_before_value.
             * @example false
             */
            reminder_due?: boolean;
            /**
             * Format: date-time
             * @example 2026-10-20T09:00:00Z
             */
            reminder_sent_at?: string;
            /** @example 2f3e4d5c-6b7a-4980-9a1b-2c3d4e5f6a7b */
            schedule_id?: string;
            /** @example Engine oil change */
            schedule_name?: string;
            /** @example oil_change */
            schedule_type?: string;
            /**
             * @example scheduled
             * @enum {string}
             */
            status?: "scheduled" | "due" | "completed" | "cancelled";
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            unit_id?: string;
            /** @example 1021 */
            unit_number?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            updated_at?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_maintenance_dto.ScheduleUnitEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ScheduleUnit"];
        };
        "github_com_devline_onebook-eld_internal_domain_maintenance_dto.ScheduleUnitInput": {
            /**
             * @description LastServiceValue is the odometer / engine hour reading of the last
             *     service in `interval_unit`. Omitted means "read it from telemetry now".
             * @example 128430
             */
            last_service_value?: number;
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            unit_id: string;
        };
        "github_com_devline_onebook-eld_internal_domain_maintenance_dto.ScheduleUnitListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ScheduleUnit"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_maintenance_dto.ScheduleUpdate": {
            /**
             * @example email
             * @enum {string}
             */
            alert_type?: "notification" | "email" | "sms" | "none";
            /**
             * @example [
             *       "push",
             *       "email"
             *     ]
             */
            delivery_methods?: string[];
            /**
             * @example km
             * @enum {string}
             */
            interval_unit?: "km" | "mi" | "days" | "engine_hours";
            /** @example 25000 */
            interval_value?: number;
            /** @example Engine oil change */
            name?: string;
            /** @example Use synthetic oil only */
            notes?: string;
            /** @example false */
            notify_co_driver?: boolean;
            /** @example 1000 */
            reminder_before_value?: number;
            /**
             * @example inactive
             * @enum {string}
             */
            status?: "active" | "inactive";
            /** @example oil_change */
            type?: string;
            /** @description Units replaces the attached fleet when present; omit to keep it as is. */
            units?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_maintenance_dto.ScheduleUnitInput"][];
        };
        "github_com_devline_onebook-eld_internal_domain_notifications_dto.ErrorResponse": {
            error?: components["schemas"]["github_com_devline_onebook-eld_internal_httpx_dto.ErrorBody"];
        };
        "github_com_devline_onebook-eld_internal_domain_notifications_dto.ListMeta": {
            /** @example 1 */
            page?: number;
            /** @example 25 */
            per_page?: number;
            /** @example 123 */
            total?: number;
            /** @example 4 */
            unread?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_notifications_dto.Notification": {
            /**
             * @example hos_violation
             * @enum {string}
             */
            alert_type?: "hos_warning" | "hos_violation" | "route_assigned" | "route_completed" | "dvir_defects" | "dvir_critical" | "log_edit_request" | "log_edit_resolved" | "uncertified_log" | "unidentified_driving" | "eld_disconnected" | "eld_malfunction" | "maintenance_upcoming" | "maintenance_overdue" | "chat_message" | "subscription_expiring";
            /** @example Driver John Doe exceeded the 11 hour driving limit at 18:05Z. */
            body?: string;
            /**
             * @example [
             *       "push",
             *       "email",
             *       "in_app"
             *     ]
             */
            channels?: string[];
            /**
             * Format: date-time
             * @example 2026-09-06T18:05:00Z
             */
            created_at?: string;
            /** @example 1f9d7c2a-4c66-4c2f-9d2f-9a0b7d1e2f34 */
            entity_id?: string;
            /** @example violations */
            entity_type?: string;
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            id?: string;
            /** @example false */
            read?: boolean;
            /**
             * Format: date-time
             * @example 2026-09-06T18:22:00Z
             */
            read_at?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T18:05:00Z
             */
            sent_at?: string;
            /** @example 11-hour driving limit exceeded */
            title?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_notifications_dto.NotificationListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.Notification"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.ListMeta"];
        };
        "github_com_devline_onebook-eld_internal_domain_notifications_dto.PushToken": {
            /** @example 1.4.2 */
            app_version?: string;
            /** @example 9f8b7c6d-1122-3344-5566-778899aabbcc */
            device_id?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T18:05:00Z
             */
            last_seen_at?: string;
            /** @example android */
            platform?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_notifications_dto.PushTokenCreate": {
            /** @example 1.4.2 */
            app_version?: string;
            /** @example 9f8b7c6d-1122-3344-5566-778899aabbcc */
            device_id: string;
            /**
             * @example android
             * @enum {string}
             */
            platform: "android" | "ios" | "web";
            /** @example fcm-registration-token */
            token: string;
        };
        "github_com_devline_onebook-eld_internal_domain_notifications_dto.PushTokenEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.PushToken"];
        };
        "github_com_devline_onebook-eld_internal_domain_notifications_dto.ReadResult": {
            /** @example 0 */
            unread?: number;
            /** @example 7 */
            updated?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_notifications_dto.ReadResultEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_notifications_dto.ReadResult"];
        };
        "github_com_devline_onebook-eld_internal_domain_reports_dto.ActivityListEnvelope": {
            /** @description Data is the page of rows. */
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ActivityRow"][];
            /** @description Meta carries the pagination counters. */
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_reports_dto.ActivityRow": {
            /**
             * @description EndOdometerM is the last odometer reading in the window, in metres.
             * @example 129180000
             */
            end_odometer_m?: number;
            /**
             * @description HasData is false when the subject reported nothing in the window, which
             *     is why its odometer columns are zero.
             * @example true
             */
            has_data?: boolean;
            /**
             * @description Name is the unit number or the driver's display name.
             * @example 1021
             */
            name?: string;
            /**
             * @description OdometerChangeM is Q75: End − Start. It is zero when the window holds no
             *     telemetry at all.
             * @example 750000
             */
            odometer_change_m?: number;
            /**
             * @description StartOdometerM is the first odometer reading in the window, in metres.
             * @example 128430000
             */
            start_odometer_m?: number;
            /**
             * @description SubjectID is the driver or unit the row describes.
             * @example 2f1a1b3c-4d5e-6f70-8192-a3b4c5d6e7f8
             */
            subject_id?: string;
            /**
             * @description SubjectType tells which of the two the row describes.
             * @example units
             * @enum {string}
             */
            subject_type?: "drivers" | "units";
        };
        "github_com_devline_onebook-eld_internal_domain_reports_dto.DistanceByRegionEnvelope": {
            /** @description Data is the report body. */
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.RegionDistanceRow"][];
            /** @description Meta describes the period the report covers. */
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.DistanceByRegionMeta"];
        };
        "github_com_devline_onebook-eld_internal_domain_reports_dto.DistanceByRegionMeta": {
            /**
             * Format: date
             * @description From is the first day of the quarter.
             * @example 2026-07-01
             */
            from?: string;
            /**
             * @description Mode is the breakdown that was requested.
             * @example regions_and_units
             * @enum {string}
             */
            mode?: "regions_and_units" | "regions_only";
            /**
             * @description Quarter is the calendar quarter, 1 to 4.
             * @example 3
             */
            quarter?: number;
            /**
             * Format: date
             * @description To is the last day of the quarter.
             * @example 2026-09-30
             */
            to?: string;
            /**
             * @description TotalDistanceM is the sum of every row, in metres.
             * @example 9184320
             */
            total_distance_m?: number;
            /**
             * @description Year is the calendar year.
             * @example 2026
             */
            year?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_reports_dto.ErrorResponse": {
            error?: components["schemas"]["github_com_devline_onebook-eld_internal_httpx_dto.ErrorBody"];
        };
        "github_com_devline_onebook-eld_internal_domain_reports_dto.ExportJob": {
            /**
             * Format: date-time
             * @description CreatedAt is when the job was queued.
             * @example 2026-09-06T05:12:00Z
             */
            created_at?: string;
            /**
             * @description DownloadURL is a presigned link, valid until ExpiresAt. It is present
             *     only while the job is `done` and inside its 24 hour window (Q75).
             * @example https://storage.example.com/onebook/…
             */
            download_url?: string;
            /**
             * @description Error carries the failure reason on a failed job.
             * @example the map provider is unavailable
             */
            error?: string;
            /**
             * Format: date-time
             * @description ExpiresAt is when the download stops working.
             * @example 2026-09-07T05:12:00Z
             */
            expires_at?: string;
            /**
             * @description FileName is the suggested download file name.
             * @example distance-by-region-2026-Q3.xlsx
             */
            file_name?: string;
            /**
             * @description FileSizeB is the rendered size in bytes.
             * @example 20480
             */
            file_size_b?: number;
            /**
             * Format: date-time
             * @description FinishedAt is when the job reached a terminal state.
             * @example 2026-09-06T05:12:31Z
             */
            finished_at?: string;
            /**
             * @description Format is the requested output format.
             * @example xlsx
             * @enum {string}
             */
            format?: "csv" | "xlsx" | "pdf" | "zip";
            /**
             * @description ID is the job identifier.
             * @example 7c9e6679-7425-40de-944b-e07fc1f90ae7
             */
            id?: string;
            /** @description Params echoes the request so the UI can label the download. */
            params?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ExportParams"];
            /**
             * @description RequestedBy is the user that asked for the export.
             * @example 3a7b1c2d-4e5f-6071-8293-a4b5c6d7e8f9
             */
            requested_by?: string;
            /**
             * Format: date-time
             * @description StartedAt is when a worker picked the job up.
             * @example 2026-09-06T05:12:03Z
             */
            started_at?: string;
            /**
             * @description Status is the job state.
             * @example done
             * @enum {string}
             */
            status?: "queued" | "running" | "done" | "failed";
            /**
             * @description Type is the report the job renders.
             * @example distance_by_region
             * @enum {string}
             */
            type?: "distance_by_region" | "regulator" | "activity" | "hos" | "dvir";
        };
        "github_com_devline_onebook-eld_internal_domain_reports_dto.ExportJobCreate": {
            /**
             * @description Format is the output format; it defaults per type when omitted.
             * @example xlsx
             * @enum {string}
             */
            format?: "csv" | "xlsx" | "pdf" | "zip";
            /** @description Params carries the report specific window and filters. */
            params?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ExportParams"];
            /**
             * @description Type is the report to render.
             * @example distance_by_region
             * @enum {string}
             */
            type: "distance_by_region" | "regulator" | "activity" | "hos" | "dvir";
        };
        "github_com_devline_onebook-eld_internal_domain_reports_dto.ExportJobEnvelope": {
            /** @description Data is the job. */
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ExportJob"];
        };
        "github_com_devline_onebook-eld_internal_domain_reports_dto.ExportJobListEnvelope": {
            /** @description Data is the page of jobs. */
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.ExportJob"][];
            /** @description Meta carries the pagination counters. */
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_reports_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_reports_dto.ExportParams": {
            /**
             * @description BranchID narrows the export to one branch. A `branch` scoped requester
             *     never controls it: the server overwrites the field with the caller's own
             *     branch before the job is stored (TZ A§16).
             * @example b1f0c2d3-4e5f-6071-8293-a4b5c6d7e8f9
             */
            branch_id?: string;
            /**
             * @description Comment is the free text the regulator export carries on its cover page.
             * @example Roadside inspection, unit 1021
             */
            comment?: string;
            /**
             * @description DriverIDs filters the export to these drivers.
             * @example [
             *       "9b2f5c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d"
             *     ]
             */
            driver_ids?: string[];
            /**
             * Format: date
             * @description From is the first day of the window (inclusive).
             * @example 2026-09-01
             */
            from?: string;
            /**
             * @description Mode is the Distance by Region breakdown.
             * @example regions_and_units
             * @enum {string}
             */
            mode?: "regions_and_units" | "regions_only";
            /**
             * @description Quarter selects the Distance by Region period.
             * @example 3
             */
            quarter?: number;
            /**
             * @description Subject is the activity report axis.
             * @example units
             * @enum {string}
             */
            subject?: "drivers" | "units";
            /**
             * Format: date
             * @description To is the last day of the window (inclusive).
             * @example 2026-09-30
             */
            to?: string;
            /**
             * @description UnitIDs filters the export to these units.
             * @example [
             *       "2f1a1b3c-4d5e-6f70-8192-a3b4c5d6e7f8"
             *     ]
             */
            unit_ids?: string[];
            /**
             * @description Year selects the Distance by Region period.
             * @example 2026
             */
            year?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_reports_dto.Meta": {
            /** @example 1 */
            page?: number;
            /** @example 25 */
            per_page?: number;
            /** @example 123 */
            total?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_reports_dto.RegionDistanceRow": {
            /**
             * @description Country is the ISO 3166-1 alpha-2 country code.
             * @example US
             */
            country?: string;
            /**
             * @description DistanceM is the distance driven inside the region, in metres.
             * @example 412345
             */
            distance_m?: number;
            /**
             * @description RegionCode is the jurisdiction code, e.g. "US-IL".
             * @example US-IL
             */
            region_code?: string;
            /**
             * @description RegionName is the jurisdiction name.
             * @example Illinois
             */
            region_name?: string;
            /**
             * @description UnitID is set only in `regions_and_units` mode.
             * @example 2f1a1b3c-4d5e-6f70-8192-a3b4c5d6e7f8
             */
            unit_id?: string;
            /**
             * @description UnitNumber is set only in `regions_and_units` mode.
             * @example 1021
             */
            unit_number?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_routes_dto.Directions": {
            /** @description Destination is the end coordinate the geometry was requested for. */
            destination?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.Waypoint"];
            /**
             * @description DistanceM is the driving distance in metres.
             * @example 412345
             */
            distance_m?: number;
            /**
             * @description DurationS is the estimated driving time in seconds.
             * @example 15600
             */
            duration_s?: number;
            /** @description Origin is the start coordinate the geometry was requested for. */
            origin?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.Waypoint"];
            /**
             * @description Polyline is the geometry in encoded polyline format (precision 5).
             * @example _p~iF~ps|U_ulLnnqC
             */
            polyline?: string;
            /**
             * @description Provider names the map provider that answered.
             * @example nominatim
             * @enum {string}
             */
            provider?: "nominatim" | "photon" | "google" | "nop";
            /**
             * @description RouteID is the route the geometry belongs to.
             * @example 7c9e6679-7425-40de-944b-e07fc1f90ae7
             */
            route_id?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_routes_dto.DirectionsEnvelope": {
            /** @description Data is the route geometry. */
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.Directions"];
        };
        "github_com_devline_onebook-eld_internal_domain_routes_dto.ErrorResponse": {
            error?: components["schemas"]["github_com_devline_onebook-eld_internal_httpx_dto.ErrorBody"];
        };
        "github_com_devline_onebook-eld_internal_domain_routes_dto.Meta": {
            /** @example 1 */
            page?: number;
            /** @example 25 */
            per_page?: number;
            /** @example 123 */
            total?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_routes_dto.Route": {
            /**
             * Format: date-time
             * @description CompletedAt is when the route reached a terminal state.
             * @example 2026-09-06T15:00:00Z
             */
            completed_at?: string;
            /**
             * Format: date-time
             * @description CreatedAt is the creation timestamp.
             * @example 2026-09-06T07:45:00Z
             */
            created_at?: string;
            /** @description Destination is the end of the leg; its geofence completes the route. */
            destination?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.Waypoint"];
            /**
             * @description DriverID is the assigned driver.
             * @example 9b2f5c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d
             */
            driver_id?: string;
            /**
             * @description DriverName is the driver's display name.
             * @example John Miller
             */
            driver_name?: string;
            /**
             * Format: date-time
             * @description GeofenceEnteredAt is when the unit was first seen inside the destination
             *     geofence; it is cleared whenever the unit leaves again.
             * @example 2026-09-06T14:58:00Z
             */
            geofence_entered_at?: string;
            /**
             * @description GeofenceM is the destination geofence radius in metres.
             * @example 300
             */
            geofence_m?: number;
            /**
             * @description ID is the route identifier.
             * @example 7c9e6679-7425-40de-944b-e07fc1f90ae7
             */
            id?: string;
            /**
             * @description NotCompletedNote is the admin's explanation.
             * @example Coolant leak on I-55
             */
            not_completed_note?: string;
            /**
             * @description NotCompletedReason is set only on a not_completed route.
             * @example breakdown
             * @enum {string}
             */
            not_completed_reason?: "breakdown" | "cancelled" | "load_rejected" | "road_closed" | "driver_change" | "other";
            /**
             * @description Note is the dispatcher's free text.
             * @example Drop at dock 4
             */
            note?: string;
            /** @description Origin is the start of the leg. */
            origin?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.Waypoint"];
            /**
             * @description Sequence orders the routes of one unit; the lowest ongoing sequence is
             *     the current one (Q68).
             * @example 1
             */
            sequence?: number;
            /**
             * Format: date-time
             * @description StartedAt is when the unit first moved on this route.
             * @example 2026-09-06T08:00:00Z
             */
            started_at?: string;
            /**
             * @description Status is the route state.
             * @example ongoing
             * @enum {string}
             */
            status?: "ongoing" | "completed" | "not_completed" | "cancelled";
            /**
             * @description UnitID is the assigned unit.
             * @example 2f1a1b3c-4d5e-6f70-8192-a3b4c5d6e7f8
             */
            unit_id?: string;
            /**
             * @description UnitNumber is the fleet number of the assigned unit.
             * @example 1021
             */
            unit_number?: string;
            /**
             * Format: date-time
             * @description UpdatedAt is the last modification timestamp.
             * @example 2026-09-06T15:00:00Z
             */
            updated_at?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_routes_dto.RouteCreate": {
            /** @description Destination is the end of the leg. */
            destination: components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.WaypointInput"];
            /**
             * @description DriverID is the driver that will be notified.
             * @example 9b2f5c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d
             */
            driver_id: string;
            /**
             * @description GeofenceM is the destination geofence radius in metres; defaults to 300.
             * @example 300
             */
            geofence_m?: number;
            /**
             * @description Note is the dispatcher's free text.
             * @example Drop at dock 4
             */
            note?: string;
            /** @description Origin is the start of the leg. */
            origin: components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.WaypointInput"];
            /**
             * @description Sequence orders several routes of the same unit (Q68); defaults to the
             *     next free slot when omitted.
             * @example 1
             */
            sequence?: number;
            /**
             * @description UnitID is the unit that will drive the leg.
             * @example 2f1a1b3c-4d5e-6f70-8192-a3b4c5d6e7f8
             */
            unit_id: string;
        };
        "github_com_devline_onebook-eld_internal_domain_routes_dto.RouteEnvelope": {
            /** @description Data is the route. */
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.Route"];
        };
        "github_com_devline_onebook-eld_internal_domain_routes_dto.RouteListEnvelope": {
            /** @description Data is the page of routes. */
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.Route"][];
            /** @description Meta carries the pagination counters. */
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_routes_dto.RouteNotCompleted": {
            /**
             * @description Note explains the closure; it is required for `other`.
             * @example Coolant leak on I-55
             */
            note?: string;
            /**
             * @description Reason is one of the fixed closure reasons.
             * @example breakdown
             * @enum {string}
             */
            reason: "breakdown" | "cancelled" | "load_rejected" | "road_closed" | "driver_change" | "other";
        };
        "github_com_devline_onebook-eld_internal_domain_routes_dto.RouteUpdate": {
            /** @description Destination replaces the end of the leg. */
            destination?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.WaypointInput"];
            /**
             * @description DriverID reassigns the driver; the new driver is notified.
             * @example 9b2f5c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d
             */
            driver_id?: string;
            /**
             * @description GeofenceM replaces the destination geofence radius in metres.
             * @example 500
             */
            geofence_m?: number;
            /**
             * @description Note replaces the dispatcher's free text.
             * @example Dock 4 closed, use dock 7
             */
            note?: string;
            /** @description Origin replaces the start of the leg. */
            origin?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_routes_dto.WaypointInput"];
            /**
             * @description Sequence reorders the route inside its unit's queue.
             * @example 2
             */
            sequence?: number;
            /**
             * @description UnitID reassigns the unit.
             * @example 2f1a1b3c-4d5e-6f70-8192-a3b4c5d6e7f8
             */
            unit_id?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_routes_dto.Waypoint": {
            /**
             * @description Lat is the WGS84 latitude in degrees.
             * @example 41.8781
             */
            lat?: number;
            /**
             * @description Lng is the WGS84 longitude in degrees.
             * @example -87.6298
             */
            lng?: number;
            /**
             * @description Text is the human readable address shown in the planner.
             * @example Chicago, IL
             */
            text?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_routes_dto.WaypointInput": {
            /**
             * @description Lat is the WGS84 latitude in degrees.
             * @example 41.8781
             */
            lat?: number;
            /**
             * @description Lng is the WGS84 longitude in degrees.
             * @example -87.6298
             */
            lng?: number;
            /**
             * @description Text is the human readable address shown in the planner.
             * @example Chicago, IL
             */
            text: string;
        };
        "github_com_devline_onebook-eld_internal_domain_support_dto.ErrorResponse": {
            error?: components["schemas"]["github_com_devline_onebook-eld_internal_httpx_dto.ErrorBody"];
        };
        "github_com_devline_onebook-eld_internal_domain_support_dto.Feedback": {
            /**
             * @description AppRating is 1..5 stars, null when the driver only left a comment.
             * @example 4
             */
            app_rating?: number;
            /** @example 2b7c4d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f */
            driver_id?: string;
            /** @example John Miller */
            driver_name?: string;
            /** @example 1a2b3c4d-5e6f-4708-8192-a3b4c5d6e7f8 */
            id?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T18:40:00Z
             */
            submitted_at?: string;
            /** @example The log screen is much faster now. */
            text?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_support_dto.FeedbackCreate": {
            /** @example 4 */
            app_rating?: number;
            /** @example The log screen is much faster now. */
            text?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_support_dto.FeedbackEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.Feedback"];
        };
        "github_com_devline_onebook-eld_internal_domain_support_dto.FeedbackListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.Feedback"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_support_dto.Meta": {
            /** @example 1 */
            page?: number;
            /** @example 25 */
            per_page?: number;
            /** @example 123 */
            total?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_support_dto.Ticket": {
            /**
             * @description Attachments are storage file keys, at most three (Q77).
             * @example [
             *       "3f1a1b3c-4d5e-6f70-8192-a3b4c5d6e7f8/chat/2026/09/photo-1.jpg"
             *     ]
             */
            attachments?: string[];
            /**
             * @description ContactOn is the channel the reporter wants an answer on (Q78).
             * @example email
             */
            contact_on?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T09:12:00Z
             */
            created_at?: string;
            /**
             * @description CreatedBy is the user that filed the ticket.
             * @example 8d3e2f1a-4b5c-4d6e-9f70-1a2b3c4d5e6f
             */
            created_by?: string;
            /** @example Anna Ross */
            creator_name?: string;
            /** @example The device drops the Bluetooth link every few minutes. */
            description?: string;
            /**
             * @description DriverID is set when the ticket was filed from the driver app.
             * @example 2b7c4d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f
             */
            driver_id?: string;
            /** @example John Miller */
            driver_name?: string;
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            id?: string;
            /** @example 3 */
            message_count?: number;
            /**
             * Format: date-time
             * @example 2026-09-07T11:30:00Z
             */
            resolved_at?: string;
            /**
             * @example new
             * @enum {string}
             */
            status?: "new" | "in_progress" | "resolved" | "closed";
            /** @example ELD device keeps disconnecting */
            subject?: string;
            /**
             * Format: date-time
             * @example 2026-09-07T11:30:00Z
             */
            updated_at?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_support_dto.TicketCreate": {
            /**
             * @description Attachments are storage file keys returned by POST /files/presign, max
             *     three. A key of another company is rejected (422).
             * @example [
             *       "3f1a1b3c-4d5e-6f70-8192-a3b4c5d6e7f8/chat/2026/09/photo-1.jpg"
             *     ]
             */
            attachments: string[];
            /**
             * @description ContactOn is the answer channel the reporter picked (Q78).
             * @example email
             * @enum {string}
             */
            contact_on?: "email" | "phone" | "sms" | "in_app";
            /** @example The device drops the Bluetooth link every few minutes. */
            description?: string;
            /** @example ELD device keeps disconnecting */
            subject: string;
        };
        "github_com_devline_onebook-eld_internal_domain_support_dto.TicketEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.Ticket"];
        };
        "github_com_devline_onebook-eld_internal_domain_support_dto.TicketListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.Ticket"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_support_dto.TicketMessage": {
            /**
             * @example [
             *       "3f1a1b3c-4d5e-6f70-8192-a3b4c5d6e7f8/chat/2026/09/reply-1.pdf"
             *     ]
             */
            attachments?: string[];
            /**
             * Format: date-time
             * @example 2026-09-07T11:30:00Z
             */
            created_at?: string;
            /** @example 3c9a1f2e-5d4b-4a6c-8e1f-0d2b3a4c5e6f */
            id?: string;
            /** @example 8d3e2f1a-4b5c-4d6e-9f70-1a2b3c4d5e6f */
            sender_id?: string;
            /** @example Anna Ross */
            sender_name?: string;
            /** @example We shipped a replacement cable today. */
            text?: string;
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            ticket_id?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_support_dto.TicketMessageCreate": {
            /**
             * @example [
             *       "3f1a1b3c-4d5e-6f70-8192-a3b4c5d6e7f8/chat/2026/09/reply-1.pdf"
             *     ]
             */
            attachments: string[];
            /** @example We shipped a replacement cable today. */
            text: string;
        };
        "github_com_devline_onebook-eld_internal_domain_support_dto.TicketMessageEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.TicketMessage"];
        };
        "github_com_devline_onebook-eld_internal_domain_support_dto.TicketMessageListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.TicketMessage"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_support_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_support_dto.TicketStatusUpdate": {
            /**
             * @example in_progress
             * @enum {string}
             */
            status: "new" | "in_progress" | "resolved";
        };
        "github_com_devline_onebook-eld_internal_domain_sync_dto.ChatMessage": {
            /**
             * Format: date-time
             * @example 2026-09-06T05:00:02Z
             */
            delivered_at?: string;
            /** @example chat/2026/09/abc.jpg */
            file_key?: string;
            /** @example 9d0e1f2a-3b4c-4d5e-8f6a-7b8c9d0e1f2a */
            id?: string;
            /**
             * @example text
             * @enum {string}
             */
            kind?: "text" | "image" | "file" | "location";
            /** @example 31.52 */
            lat?: number;
            /** @example 74.35 */
            lng?: number;
            /**
             * Format: date-time
             * @example 2026-09-06T05:01:00Z
             */
            read_at?: string;
            /** @example 0e1f2a3b-4c5d-4e6f-8a7b-8c9d0e1f2a3b */
            sender_id?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T05:00:00Z
             */
            sent_at?: string;
            /** @example Please call dispatch */
            text?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T05:01:00Z
             */
            updated_at?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_sync_dto.ChatPush": {
            /**
             * @description ClientID is the device generated idempotency key of the message.
             * @example 55555555-5555-4555-8555-555555555555
             */
            client_id: string;
        };
        "github_com_devline_onebook-eld_internal_domain_sync_dto.Clock": {
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            eld_rtc?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:03Z
             */
            phone?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_sync_dto.ClockVerdict": {
            /**
             * @description SkewSec is phone minus reference clock, in seconds.
             * @example 0
             */
            clock_skew_sec?: number;
            /**
             * @description MalfunctionCode is the FMCSA Appendix A letter to raise above ten
             *     minutes of drift ("T", timing compliance); empty when the clock is fine.
             * @example
             * @enum {string}
             */
            malfunction_code?: "T";
            /**
             * @description Source is the clock the events were stamped from.
             * @example eld_rtc
             * @enum {string}
             */
            source?: "eld_rtc" | "server" | "phone";
            /**
             * @description TimeUnverified marks a batch whose only clock was the phone.
             * @example false
             */
            time_unverified?: boolean;
            /**
             * @description Warning is raised above two minutes of drift: tell the driver.
             * @example false
             */
            warning?: boolean;
        };
        "github_com_devline_onebook-eld_internal_domain_sync_dto.DailyLogSummary": {
            /**
             * @example uncertified
             * @enum {string}
             */
            certification_status?: "uncertified" | "certified" | "needs_recertify";
            /** @example 412000 */
            distance_m?: number;
            /** @example 4b5c6d7e-8f90-41a2-b3c4-d5e6f7a8b9c0 */
            id?: string;
            /**
             * Format: date
             * @example 2026-09-06
             */
            log_date?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T23:50:00Z
             */
            signed_at?: string;
            /** @example America/Chicago */
            timezone?: string;
            /** @description Totals are the four duty-line minutes of the day. */
            totals?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_duty_dto.DayTotals"];
            /**
             * Format: date-time
             * @example 2026-09-06T23:50:01Z
             */
            updated_at?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_sync_dto.DefectType": {
            /**
             * @example truck
             * @enum {string}
             */
            category?: "truck" | "trailer";
            /** @example 8c9d0e1f-2a3b-4c4d-8e5f-6a7b8c9d0e1f */
            id?: string;
            /** @example true */
            is_critical?: boolean;
            /** @example Brakes */
            name?: string;
            /** @example 10 */
            sort_order?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_sync_dto.DutyStatusEvent": {
            /** @example 11111111-1111-4111-8111-111111111111 */
            client_event_id?: string;
            /**
             * @description ClockSkewSec is phone minus reference clock, in seconds.
             * @example 0
             */
            clock_skew_sec?: number;
            /** @example 4b5c6d7e-8f90-41a2-b3c4-d5e6f7a8b9c0 */
            daily_log_id?: string;
            /** @example 1042 */
            device_seq?: number;
            /** @example 1234.5 */
            engine_hours?: number;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            event_time?: string;
            /**
             * @example duty_status
             * @enum {string}
             */
            event_type?: "duty_status" | "intermediate" | "login" | "logout" | "power_on" | "power_off" | "engine_on" | "engine_off" | "malfunction" | "diagnostic" | "certification" | "yard_moves" | "personal_use";
            /** @example 12 */
            gps_accuracy_m?: number;
            /** @example 7d1e2f3a-4b5c-4d6e-8f90-1a2b3c4d5e6f */
            id?: string;
            /** @example 31.52 */
            lat?: number;
            /** @example 74.35 */
            lng?: number;
            /** @example 12 km NE of Lahore */
            location_text?: string;
            /** @example false */
            locked?: boolean;
            /** @example Pickup */
            notes?: string;
            /** @example 128430000 */
            odometer_m?: number;
            /**
             * @example auto
             * @enum {string}
             */
            origin?: "auto" | "driver" | "driver_edit" | "admin_edit" | "assigned" | "manual_no_eld";
            /**
             * Format: date-time
             * @example 2026-09-06T05:14:11Z
             */
            received_at?: string;
            /**
             * @example [
             *       "1c2d3e4f-5a6b-4c7d-8e9f-0a1b2c3d4e5f"
             *     ]
             */
            shipping_doc_ids?: string[];
            /**
             * @example none
             * @enum {string}
             */
            special?: "none" | "pc" | "ym";
            /**
             * @example ON
             * @enum {string}
             */
            status?: "OFF" | "SB" | "DR" | "ON";
            /**
             * @description SupersededBy points at the event that won conflict rule 1; a superseded
             *     event stays in the log and never disappears.
             * @example 8a9b0c1d-2e3f-4a5b-8c6d-7e8f9a0b1c2d
             */
            superseded_by?: string;
            /**
             * @description TimeSource is the clock the event_time came from (Q-B1.2).
             * @example eld_rtc
             * @enum {string}
             */
            time_source?: "eld_rtc" | "server" | "phone";
            /**
             * @description TimeUnverified marks an event stamped from the phone only; the admin log
             *     shows it with a yellow marker (Q7.1).
             * @example false
             */
            time_unverified?: boolean;
            /**
             * @example [
             *       "9f8e7d6c-5b4a-4392-8281-706f5e4d3c2b"
             *     ]
             */
            trailer_ids?: string[];
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            unit_id?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_sync_dto.DvirPush": {
            /**
             * @description ClientID is the device generated idempotency key of the report.
             * @example 44444444-4444-4444-8444-444444444444
             */
            client_id: string;
        };
        "github_com_devline_onebook-eld_internal_domain_sync_dto.ElementResult": {
            /**
             * @description ClientEventID echoes the element's idempotency key.
             * @example 11111111-1111-4111-8111-111111111111
             */
            client_event_id?: string;
            /**
             * @description Field names the offending field of an invalid_payload rejection.
             * @example event_time
             */
            field?: string;
            /**
             * @description Reason explains a rejection, and annotates an accepted event that the
             *     server changed or that lost conflict rule 1.
             * @example time_in_future
             * @enum {string}
             */
            reason?: "time_in_future" | "time_out_of_range" | "log_locked" | "invalid_payload" | "superseded" | "pc_not_allowed" | "ym_not_allowed" | "sleeper_berth_unavailable" | "drive_not_manual" | "auto_drive" | "yard_move_ended";
            /**
             * @example accepted
             * @enum {string}
             */
            result?: "accepted" | "duplicate" | "rejected";
            /**
             * @description SupersededBy is the client_event_id that won conflict rule 1. The losing
             *     event is still stored, flagged, and shown to the driver as a warning.
             * @example 22222222-2222-4222-8222-222222222222
             */
            superseded_by?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_sync_dto.ErrorResponse": {
            error?: components["schemas"]["github_com_devline_onebook-eld_internal_httpx_dto.ErrorBody"];
        };
        "github_com_devline_onebook-eld_internal_domain_sync_dto.EventPush": {
            /**
             * @description ClientEventID is the device generated idempotency key. Re-uploading it
             *     answers `duplicate`, never an error.
             * @example 11111111-1111-4111-8111-111111111111
             */
            client_event_id: string;
            /**
             * @description DeviceSeq is the monotonic device counter; retries preserve its order
             *     and it breaks a conflict tie between two devices (rule 1).
             * @example 1042
             */
            device_seq?: number;
            /** @example 9c3f2f1e-2b4a-4f7d-9a1e-0f2b3c4d5e6f */
            eld_device_id?: string;
            /** @example 1234.5 */
            engine_hours?: number;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            event_time: string;
            /**
             * @example status_change
             * @enum {string}
             */
            event_type: "status_change" | "duty_status" | "intermediate" | "login" | "logout" | "power_on" | "power_off" | "engine_on" | "engine_off" | "malfunction" | "diagnostic" | "certification" | "yard_moves" | "personal_use";
            /** @example 12 */
            gps_accuracy_m?: number;
            /** @example 31.52 */
            lat?: number;
            /** @example 74.35 */
            lng?: number;
            /** @example 12 km NE of Lahore */
            location_text?: string;
            /** @example Pickup */
            notes?: string;
            /** @example 128430000 */
            odometer_m?: number;
            /**
             * @description Origin records how the event came to be. `manual_no_eld` marks a status
             *     entered with the ELD disconnected (Q7.1). `driver_edit`, `admin_edit`
             *     and `assigned` are server side origins (log edit approval, §10.4 hand
             *     over) and are refused here with `rejected(invalid_payload)`.
             * @example driver
             * @enum {string}
             */
            origin?: "auto" | "driver" | "manual_no_eld";
            /**
             * @example [
             *       "1c2d3e4f-5a6b-4c7d-8e9f-0a1b2c3d4e5f"
             *     ]
             */
            shipping_doc_ids?: string[];
            /**
             * @example none
             * @enum {string}
             */
            special?: "none" | "pc" | "ym";
            /**
             * @description SpeedKmh at event_time drives the server side auto-DR and yard-move exit
             *     checks (Q5, Q4.2).
             * @example 62.5
             */
            speed_kmh?: number;
            /**
             * @example ON
             * @enum {string}
             */
            status?: "OFF" | "SB" | "DR" | "ON";
            /**
             * @description TimeSource is the clock event_time came from (Q-B1.2).
             * @example eld_rtc
             * @enum {string}
             */
            time_source?: "eld_rtc" | "server" | "phone";
            /**
             * @example [
             *       "9f8e7d6c-5b4a-4392-8281-706f5e4d3c2b"
             *     ]
             */
            trailer_ids?: string[];
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            unit_id?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_sync_dto.HosPolicy": {
            /** @example 120 */
            adverse_conditions_extension_min?: number;
            /** @example true */
            allow_pc?: boolean;
            /** @example true */
            allow_ym?: boolean;
            /** @example 30 */
            break_duration_min?: number;
            /**
             * @example [
             *       "OFF",
             *       "SB",
             *       "ON"
             *     ]
             */
            break_qualifying_statuses?: ("OFF" | "SB" | "DR" | "ON")[];
            /** @example 480 */
            break_required_after_drive_min?: number;
            /** @example 8 */
            cycle_days?: number;
            /** @example 4200 */
            cycle_limit_min?: number;
            /**
             * @description CycleRestartMin is null when the policy has no restart provision.
             * @example 2040
             */
            cycle_restart_min?: number;
            /** @example 600 */
            daily_rest_min?: number;
            /** @example 660 */
            drive_limit_min?: number;
            /**
             * Format: date-time
             * @example 2026-01-01T00:00:00Z
             */
            effective_from?: string;
            /** @example 8 */
            motion_threshold_kmh?: number;
            /** @example 840 */
            shift_window_min?: number;
            /** @example false */
            short_haul_exception?: boolean;
            /** @example true */
            sleeper_split_enabled?: boolean;
            /**
             * @description VersionID is the hos_policy_versions row; null means the built-in
             *     FMCSA 70/8 defaults.
             * @example 2f3a4b5c-6d7e-4f80-9a1b-2c3d4e5f6a7b
             */
            version_id?: string;
            /** @example 30 */
            warn_break_min?: number;
            /** @example 120 */
            warn_cycle_min?: number;
            /** @example 30 */
            warn_drive_min?: number;
            /** @example 60 */
            warn_shift_min?: number;
            /** @example 32 */
            ym_max_speed_kmh?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_sync_dto.LogEditRequest": {
            /** @description Changes are the proposed duty status intervals; `note` is always set. */
            changes?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_logs_dto.LogEditChange"][];
            /**
             * Format: date-time
             * @example 2026-09-05T09:00:00Z
             */
            created_at?: string;
            /** @example 4b5c6d7e-8f90-41a2-b3c4-d5e6f7a8b9c0 */
            daily_log_id?: string;
            /** @example 7b8c9d0e-1f2a-4b3c-8d4e-5f6a7b8c9d0e */
            id?: string;
            /**
             * Format: date
             * @description LogDate is the home terminal calendar day the proposal touches (Q10.2).
             * @example 2026-09-05
             */
            log_date?: string;
            /**
             * @example admin_edit
             * @enum {string}
             */
            source?: "admin_edit" | "unidentified_assign";
            /**
             * @example pending
             * @enum {string}
             */
            status?: "pending" | "approved" | "rejected";
            /** @example America/Chicago */
            timezone?: string;
            /**
             * Format: date-time
             * @example 2026-09-05T09:00:00Z
             */
            updated_at?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_sync_dto.PullEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.PullResponse"];
        };
        "github_com_devline_onebook-eld_internal_domain_sync_dto.PullResponse": {
            chat?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.ChatMessage"][];
            daily_logs?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.DailyLogSummary"][];
            defect_types?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.DefectType"][];
            /**
             * @description Events are the server's canonical copies of changed duty status events
             *     (rule 2: the server wins, the device rebuilds its local log).
             */
            events?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.DutyStatusEvent"][];
            hos_policy?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.HosPolicy"];
            log_edit_requests?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.LogEditRequest"][];
            /**
             * Format: date-time
             * @description NextSince is the cursor to send on the next pull. It is the newest
             *     `updated_at` actually returned, so a truncated page is resumed exactly.
             * @example 2026-09-06T05:13:59Z
             */
            next_since?: string;
            /**
             * @example [
             *       "Pickup",
             *       "Delivery",
             *       "Fuel"
             *     ]
             */
            quick_notes?: string[];
            /**
             * Format: date-time
             * @example 2026-09-06T05:14:11Z
             */
            server_time?: string;
            /**
             * @description Truncated is true when a list hit its ceiling: pull again immediately
             *     with next_since.
             * @example false
             */
            truncated?: boolean;
            unidentified_events?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.UnidentifiedEvent"][];
        };
        "github_com_devline_onebook-eld_internal_domain_sync_dto.PushEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.PushResponse"];
        };
        "github_com_devline_onebook-eld_internal_domain_sync_dto.PushRequest": {
            /** @example 1.2.0 */
            app_version?: string;
            chat?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.ChatPush"][];
            clock?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.Clock"];
            /**
             * @description DeviceID identifies the uploading phone; it namespaces the per device
             *     rate limit and is echoed into the audit trail.
             * @example a1b2c3d4-e5f6-4718-9a0b-1c2d3e4f5a6b
             */
            device_id: string;
            dvir?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.DvirPush"][];
            events?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.EventPush"][];
            telemetry?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.TelemetryPoint"][];
            /**
             * @description UnitID is the unit the telemetry belongs to; required when `telemetry`
             *     is not empty.
             * @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f
             */
            unit_id?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_sync_dto.PushResponse": {
            chat?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.ElementResult"][];
            clock?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.ClockVerdict"];
            dvir?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.ElementResult"][];
            events?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.ElementResult"][];
            /**
             * Format: date-time
             * @example 2026-09-06T05:14:11Z
             */
            server_time?: string;
            telemetry?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_sync_dto.TelemetryResult"];
        };
        "github_com_devline_onebook-eld_internal_domain_sync_dto.TelemetryPoint": {
            /** @example 87 */
            battery_pct?: number;
            /** @example 13.8 */
            battery_voltage_v?: number;
            /** @example 92 */
            coolant_level_pct?: number;
            /** @example 88 */
            coolant_temp_c?: number;
            /**
             * @description Diagnostics are the FMCSA Appendix A letters active at TS (TZ §10.5).
             *     Send an empty array to clear the stored codes; omit the field to leave
             *     them untouched.
             * @example [
             *       "T",
             *       "L"
             *     ]
             */
            diagnostics?: string[];
            /**
             * @description Disconnected marks the sample the ELD sends when it loses the link to the
             *     phone (TZ §10.1 "Disconnected").
             * @example false
             */
            disconnected?: boolean;
            /**
             * @description DriverID is null for unidentified driving (TZ A§10.4); the sample then
             *     opens or extends an unidentified_events buffer entry.
             * @example 3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b
             */
            driver_id?: string;
            /**
             * @description DutyStatus is the duty status in force at TS, when known.
             * @example DR
             * @enum {string}
             */
            duty_status?: "OFF" | "SB" | "DR" | "ON";
            /**
             * @description EngineHours is the ECM total engine time in hours.
             * @example 1234.5
             */
            engine_hours?: number;
            /** @example 74 */
            fuel_pct?: number;
            /** @example 180 */
            heading_deg?: number;
            /** @example true */
            ignition?: boolean;
            /** @example 31.52 */
            lat?: number;
            /** @example 74.35 */
            lng?: number;
            /**
             * @description OdometerM is the ECM total distance in metres.
             * @example 128430000
             */
            odometer_m?: number;
            /** @example 60 */
            oil_level_pct?: number;
            /** @example 62.5 */
            speed_kmh?: number;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            ts: string;
        };
        "github_com_devline_onebook-eld_internal_domain_sync_dto.TelemetryResult": {
            /** @example 120 */
            accepted?: number;
            /**
             * @description DistanceM is the distance the accepted samples added to the unit.
             * @example 12400
             */
            distance_m?: number;
            /** @example 3 */
            duplicate?: number;
            /** @example 0 */
            rejected?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_sync_dto.UnidentifiedEvent": {
            /** @example 18400 */
            distance_m?: number;
            /**
             * Format: date-time
             * @example 2026-09-05T14:35:00Z
             */
            end_at?: string;
            /** @example 6a7b8c9d-0e1f-4a2b-8c3d-4e5f6a7b8c9d */
            id?: string;
            /**
             * Format: date-time
             * @example 2026-09-05T14:00:00Z
             */
            start_at?: string;
            /**
             * @example pending
             * @enum {string}
             */
            status?: "pending" | "assigned" | "annotated";
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            unit_id?: string;
            /** @example 1021 */
            unit_number?: string;
            /**
             * Format: date-time
             * @example 2026-09-05T14:36:02Z
             */
            updated_at?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_tracking_dto.DriverBrief": {
            /** @example John */
            first_name?: string;
            /** @example 3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b */
            id?: string;
            /** @example Doe */
            last_name?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_tracking_dto.ErrorResponse": {
            error?: components["schemas"]["github_com_devline_onebook-eld_internal_httpx_dto.ErrorBody"];
        };
        "github_com_devline_onebook-eld_internal_domain_tracking_dto.LiveUnit": {
            /** @example 2b7c4d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f */
            branch_id?: string;
            /** @example Dallas terminal */
            branch_name?: string;
            driver?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.DriverBrief"];
            /**
             * @description DutyStatus is the HOS status of the driver at the wheel.
             * @example DR
             * @enum {string}
             */
            duty_status?: "OFF" | "SB" | "DR" | "ON";
            /** @example 9c3f2f1e-2b4a-4f7d-9a1e-0f2b3c4d5e6f */
            eld_device_id?: string;
            /** @example ELD-000123 */
            eld_device_serial?: string;
            /** @example 1234.5 */
            engine_hours?: number;
            /** @example 180 */
            heading_deg?: number;
            /**
             * Format: date-time
             * @description LastSeenAt is the timestamp of the last telemetry sample, null when the
             *     unit has never reported.
             * @example 2026-09-06T05:12:00Z
             */
            last_seen_at?: string;
            /** @example 31.52 */
            lat?: number;
            /** @example 74.35 */
            lng?: number;
            /**
             * @example [
             *       "T",
             *       "L"
             *     ]
             */
            malfunction_codes?: string[];
            /** @example 128430000 */
            odometer_m?: number;
            /**
             * @description OnlineStatus is Online / Offline / Disconnected / Malfunction (TZ §10.1).
             * @example online
             * @enum {string}
             */
            online_status?: "online" | "offline" | "disconnected" | "malfunction";
            /**
             * @description OutOfService mirrors units.out_of_service.
             * @example false
             */
            out_of_service?: boolean;
            /** @example 62.5 */
            speed_kmh?: number;
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            unit_id?: string;
            /** @example 1021 */
            unit_number?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_tracking_dto.LiveUnitListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.LiveUnit"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_tracking_dto.Meta": {
            /** @example 1 */
            page?: number;
            /** @example 25 */
            per_page?: number;
            /** @example 123 */
            total?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_tracking_dto.Trip": {
            /**
             * @description DistanceM is metres; DurationSec is seconds; MaxSpeedKmh is km/h.
             * @example 152300
             */
            distance_m?: number;
            driver?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.DriverBrief"];
            /** @example 9120 */
            duration_sec?: number;
            /**
             * Format: date-time
             * @example 2026-09-06T07:44:00Z
             */
            end_at?: string;
            /** @example 31.98 */
            end_lat?: number;
            /** @example 74.91 */
            end_lng?: number;
            /** @example 1d2c3b4a-5e6f-4708-8192-a3b4c5d6e7f8 */
            id?: string;
            /** @example 104.2 */
            max_speed_kmh?: number;
            /**
             * @description Open is true while the trip has no end yet.
             * @example false
             */
            open?: boolean;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            start_at?: string;
            /** @example 31.52 */
            start_lat?: number;
            /** @example 74.35 */
            start_lng?: number;
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            unit_id?: string;
            /** @example 1021 */
            unit_number?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_tracking_dto.TripDetail": {
            /**
             * @description DistanceM is metres; DurationSec is seconds; MaxSpeedKmh is km/h.
             * @example 152300
             */
            distance_m?: number;
            driver?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.DriverBrief"];
            /** @example 9120 */
            duration_sec?: number;
            /**
             * Format: date-time
             * @example 2026-09-06T07:44:00Z
             */
            end_at?: string;
            /** @example 31.98 */
            end_lat?: number;
            /** @example 74.91 */
            end_lng?: number;
            /** @example 1d2c3b4a-5e6f-4708-8192-a3b4c5d6e7f8 */
            id?: string;
            /** @example 104.2 */
            max_speed_kmh?: number;
            /**
             * @description Open is true while the trip has no end yet.
             * @example false
             */
            open?: boolean;
            /**
             * @description PointCount is how many fixes the polyline was built from.
             * @example 412
             */
            point_count?: number;
            /**
             * @description Polyline is the Google encoded polyline (precision 5) rebuilt from the
             *     telemetry of the trip window. Empty when include_polyline=false or when
             *     the samples fell outside the retention window.
             * @example _p~iF~ps|U_ulLnnqC
             */
            polyline?: string;
            /**
             * @description PolylineKey is the object storage key of the stored track, null when the
             *     trip was never closed or the upload failed.
             * @example 6f1a1a5e/trips/2026/09/9d1c0f4e.polyline
             */
            polyline_key?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            start_at?: string;
            /** @example 31.52 */
            start_lat?: number;
            /** @example 74.35 */
            start_lng?: number;
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            unit_id?: string;
            /** @example 1021 */
            unit_number?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_tracking_dto.TripEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.TripDetail"];
        };
        "github_com_devline_onebook-eld_internal_domain_tracking_dto.TripListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.Trip"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_tracking_dto.UnidentifiedEvent": {
            /** @example Workshop test drive */
            annotation?: string;
            /**
             * @description AssignedDriverID is set once an admin assignment or a driver claim
             *     resolved the event.
             * @example 3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b
             */
            assigned_driver_id?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T05:31:04Z
             */
            created_at?: string;
            /**
             * @description DistanceM is metres driven without an identified driver.
             * @example 8400
             */
            distance_m?: number;
            /**
             * Format: date-time
             * @example 2026-09-06T05:31:00Z
             */
            end_at?: string;
            /** @example 7c8d9e0f-1a2b-4c3d-8e4f-5a6b7c8d9e0f */
            id?: string;
            /**
             * @description PendingDays is how long the event has been unresolved; beyond 8 days it
             *     raises an admin alert (TZ A§10.4).
             * @example 3
             */
            pending_days?: number;
            /**
             * Format: date-time
             * @example 2026-09-08T09:00:00Z
             */
            resolved_at?: string;
            /**
             * Format: date-time
             * @example 2026-09-06T05:12:00Z
             */
            start_at?: string;
            /**
             * @example pending
             * @enum {string}
             */
            status?: "pending" | "assigned" | "annotated";
            /**
             * @description TrackKey is the object storage key of the recorded track.
             * @example 6f1a1a5e/unidentified/2026/09/2b7c4d1a.polyline
             */
            track_key?: string;
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            unit_id?: string;
            /** @example 1021 */
            unit_number?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_tracking_dto.UnidentifiedEventListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.UnidentifiedEvent"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_tracking_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_users_dto.ErrorResponse": {
            error?: components["schemas"]["github_com_devline_onebook-eld_internal_httpx_dto.ErrorBody"];
        };
        "github_com_devline_onebook-eld_internal_domain_users_dto.InvitationEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.InvitationSent"];
        };
        "github_com_devline_onebook-eld_internal_domain_users_dto.InvitationSent": {
            /**
             * @example email
             * @enum {string}
             */
            channel?: "email" | "sms" | "telegram";
            /**
             * Format: date-time
             * @example 2026-09-04T10:00:00Z
             */
            expires_at?: string;
            /**
             * @example invitation
             * @enum {string}
             */
            purpose?: "invitation" | "password_reset";
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            user_id?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_users_dto.Meta": {
            /** @example 1 */
            page?: number;
            /** @example 25 */
            per_page?: number;
            /** @example 123 */
            total?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_users_dto.Permission": {
            /** @example View units */
            description?: string;
            /** @example units.read */
            key?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_users_dto.PermissionListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.PermissionModule"][];
        };
        "github_com_devline_onebook-eld_internal_domain_users_dto.PermissionModule": {
            /** @example Units */
            label?: string;
            /** @example units */
            module?: string;
            /** @description Permissions are ordered exactly like the catalogue. */
            permissions?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.Permission"][];
        };
        "github_com_devline_onebook-eld_internal_domain_users_dto.Role": {
            /**
             * Format: date-time
             * @example 2026-09-01T10:00:00Z
             */
            created_at?: string;
            /** @example Fleet and driver management */
            description?: string;
            /** @example 9d1b7f3e-4c2a-4a1b-9e7d-2f5a6b8c0d1e */
            id?: string;
            /**
             * @description IsSystem roles (Super Admin, Administrator, ...) cannot be edited.
             * @example false
             */
            is_system?: boolean;
            /** @example Fleet Manager */
            name?: string;
            /**
             * @example [
             *       "units.read",
             *       "units.create"
             *     ]
             */
            permissions?: string[];
            /**
             * @description Scope decides how far a holder of the role can see (TZ Q82.1).
             * @example company
             * @enum {string}
             */
            scope?: "company" | "branch" | "self";
            /**
             * Format: date-time
             * @example 2026-09-05T17:42:00Z
             */
            updated_at?: string;
            /** @example 7 */
            user_count?: number;
        };
        "github_com_devline_onebook-eld_internal_domain_users_dto.RoleCreate": {
            /** @example Yard operations only */
            description?: string;
            /** @example Yard Supervisor */
            name: string;
            /**
             * @description Permissions must be keys of GET /permissions; unknown keys are rejected.
             * @example [
             *       "units.read",
             *       "drivers.read"
             *     ]
             */
            permissions: string[];
            /**
             * @description Scope is company or branch; `self` is reserved for the built in Driver role.
             * @example company
             * @enum {string}
             */
            scope: "company" | "branch";
        };
        "github_com_devline_onebook-eld_internal_domain_users_dto.RoleEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.Role"];
        };
        "github_com_devline_onebook-eld_internal_domain_users_dto.RoleListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.Role"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_users_dto.RoleUpdate": {
            /** @example Yard operations only */
            description?: string;
            /** @example Yard Supervisor */
            name?: string;
            /**
             * @description Permissions replaces the whole set when present.
             * @example [
             *       "units.read",
             *       "drivers.read"
             *     ]
             */
            permissions: string[];
            /**
             * @example branch
             * @enum {string}
             */
            scope?: "company" | "branch";
        };
        "github_com_devline_onebook-eld_internal_domain_users_dto.User": {
            /**
             * Format: date-time
             * @example 2026-09-02T08:15:00Z
             */
            activated_at?: string;
            /** @example 2b7c9d1e-3f4a-4b5c-8d9e-0f1a2b3c4d5e */
            branch_id?: string;
            /** @example Chicago */
            branch_name?: string;
            /**
             * Format: date-time
             * @example 2026-09-01T10:00:00Z
             */
            created_at?: string;
            /** @example john.doe@example.com */
            email?: string;
            /** @example John */
            first_name?: string;
            /** @example John Doe */
            full_name?: string;
            /** @example 6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f */
            id?: string;
            /**
             * Format: date-time
             * @example 2026-09-01T10:00:00Z
             */
            invited_at?: string;
            /**
             * Format: date-time
             * @example 2026-09-05T17:42:00Z
             */
            last_login_at?: string;
            /** @example Doe */
            last_name?: string;
            /** @example +13125550142 */
            phone?: string;
            role?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.UserRole"];
            /**
             * @description Status follows TZ Q1: invited -> active, active <-> inactive.
             * @example active
             * @enum {string}
             */
            status?: "invited" | "active" | "inactive";
            /** @example false */
            totp_enabled?: boolean;
            /**
             * Format: date-time
             * @example 2026-09-05T17:42:00Z
             */
            updated_at?: string;
            /** @example jdoe */
            username?: string;
        };
        "github_com_devline_onebook-eld_internal_domain_users_dto.UserCreate": {
            /**
             * @description BranchID is required for a branch scoped role.
             * @example 2b7c9d1e-3f4a-4b5c-8d9e-0f1a2b3c4d5e
             */
            branch_id?: string;
            /**
             * @description Channel selects how the invitation is delivered; empty picks email when
             *     an address is present, otherwise sms.
             * @example email
             * @enum {string}
             */
            channel?: "email" | "sms" | "telegram";
            /**
             * @description Email or Phone is required: it is the channel the invitation is sent on.
             * @example john.doe@example.com
             */
            email?: string;
            /** @example John */
            first_name: string;
            /** @example Doe */
            last_name: string;
            /** @example +13125550142 */
            phone?: string;
            /** @example 9d1b7f3e-4c2a-4a1b-9e7d-2f5a6b8c0d1e */
            role_id: string;
            /**
             * @description Username must be unique inside the company.
             * @example jdoe
             */
            username: string;
        };
        "github_com_devline_onebook-eld_internal_domain_users_dto.UserEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.User"];
        };
        "github_com_devline_onebook-eld_internal_domain_users_dto.UserListEnvelope": {
            data?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.User"][];
            meta?: components["schemas"]["github_com_devline_onebook-eld_internal_domain_users_dto.Meta"];
        };
        "github_com_devline_onebook-eld_internal_domain_users_dto.UserRole": {
            /** @example 9d1b7f3e-4c2a-4a1b-9e7d-2f5a6b8c0d1e */
            id?: string;
            /** @example false */
            is_system?: boolean;
            /** @example Fleet Manager */
            name?: string;
            /**
             * @example company
             * @enum {string}
             */
            scope?: "company" | "branch" | "self";
        };
        "github_com_devline_onebook-eld_internal_domain_users_dto.UserUpdate": {
            /**
             * @description BranchID accepts an explicit null to detach the user from its branch.
             * @example 2b7c9d1e-3f4a-4b5c-8d9e-0f1a2b3c4d5e
             */
            branch_id?: string;
            /** @example john.doe@example.com */
            email?: string;
            /** @example John */
            first_name?: string;
            /** @example Doe */
            last_name?: string;
            /** @example +13125550142 */
            phone?: string;
            /** @example 9d1b7f3e-4c2a-4a1b-9e7d-2f5a6b8c0d1e */
            role_id?: string;
            /** @example jdoe */
            username?: string;
        };
        "github_com_devline_onebook-eld_internal_httpx_dto.ErrorBody": {
            /** @example VALIDATION_ERROR */
            code?: string;
            details?: components["schemas"]["github_com_devline_onebook-eld_internal_httpx_dto.FieldError"][];
            /** @example validation failed */
            message?: string;
        };
        "github_com_devline_onebook-eld_internal_httpx_dto.FieldError": {
            /** @example unit_number */
            field?: string;
            /** @example required */
            message?: string;
        };
        "github_com_devline_onebook-eld_internal_httpx_dto.MessageResponse": {
            /** @example ok */
            message?: string;
        };
    };
    responses: never;
    parameters: never;
    requestBodies: {
        /** @description Fields to change */
        "github_com_devline_onebook-eld_internal_domain_fleet_dto.CatalogUpdate": {
            content: {
                "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_fleet_dto.CatalogUpdate"];
            };
        };
        /** @description Optional reason for the audit trail */
        "github_com_devline_onebook-eld_internal_domain_drivers_dto.StatusChange": {
            content: {
                "application/json": components["schemas"]["github_com_devline_onebook-eld_internal_domain_drivers_dto.StatusChange"];
            };
        };
        postDriversImport: {
            content: {
                "multipart/form-data": {
                    /**
                     * Format: binary
                     * @description CSV or XLSX file
                     */
                    file: string;
                };
            };
        };
    };
    headers: never;
    pathItems: never;
}
export type $defs = Record<string, never>;
export type operations = Record<string, never>;
