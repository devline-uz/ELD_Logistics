---
name: eld-swagger
description: swaggo (code-first Swagger) annotatsiya formati, DTO teglari va docs/ generatsiya qoidalari. HTTP handler yoki DTO yozayotganda majburiy.
---

# Swagger — code-first (swaggo) [MUST] (TZ B§6.4)

`openapi.yaml` QO'LDA YOZILMAYDI. Manba — Go izohlari.

## Handler annotatsiyasi (majburiy format)
```go
// CreateUnit godoc
// @Summary      Create unit
// @Description  Q18.1 — required: unit_number, make, model, license_plate, fuel_type.
// @Tags         units
// @Accept       json
// @Produce      json
// @Param        body  body      dto.UnitCreate  true  "Unit payload"
// @Success      201   {object}  dto.UnitEnvelope
// @Failure      401   {object}  dto.ErrorResponse
// @Failure      403   {object}  dto.ErrorResponse
// @Failure      409   {object}  dto.ErrorResponse  "UNIQUE_VIOLATION"
// @Failure      422   {object}  dto.ErrorResponse  "VALIDATION_ERROR"
// @Security     BearerAuth
// @x-permission units.create
// @Router       /units [post]
```

## Qoidalar [MUST]
1. Har handlerda: `@Summary`, `@Tags`, `@Security BearerAuth`, `@x-permission <kalit>` (agar public bo'lsa `@x-permission public`), `@Router`, va **barcha real xato kodlari**.
2. Har eksport DTO maydonida `json` + `example` teglari; enum bo'lsa `enums`; majburiy bo'lsa `validate:"required"`.
   ```go
   type UnitCreate struct {
       UnitNumber string `json:"unit_number" example:"1021" validate:"required,max=32"`
       FuelType   string `json:"fuel_type" example:"diesel" enums:"diesel,petrol,cng,lpg,electric,hybrid" validate:"required"`
       OdometerM  int64  `json:"odometer_m" example:"128430000"`
   }
   ```
   **Misolsiz (`example`siz) maydon qolmasin.**
3. Umumiy envelope tiplari `internal/httpx/dto` yoki har domen `dto` da: `XEnvelope{Data X}`, `XListEnvelope{Data []X; Meta Pagination}`, `ErrorResponse{Error ErrorBody}`.
4. `cmd/api/main.go` da umumiy annotatsiyalar:
   `// @title ONEBOOK ELD API` `// @version 1.0` `// @BasePath /api/v1`
   `// @securityDefinitions.apikey BearerAuth` `// @in header` `// @name Authorization`
5. Swagger UI: `GET /api/docs/index.html` (http-swagger), xom spec `GET /api/docs/swagger.json`.
6. `swag init -g cmd/api/main.go -o docs --parseDependency --parseInternal` — natija `docs/` commit qilinadi; CI'da `git diff --exit-code docs/`.
7. WebSocket kanallari Swagger'ga tushmaydi — `docs/websocket.md` qo'lda (kanal, subscribe formati, xabar JSON namunasi).
8. Endpoint nomlari TZ QISM D §3 jadvaliga **aynan** mos (eld-api-contract skill).
