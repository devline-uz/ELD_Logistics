package httpx

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"reflect"
	"strings"
	"sync"

	"github.com/go-playground/validator/v10"

	"github.com/devline/onebook-eld/internal/apierr"
)

var (
	validateOnce sync.Once
	validate     *validator.Validate
)

// Validator returns the process wide validator instance. Field names are taken
// from the json tag so error details match the wire contract.
func Validator() *validator.Validate {
	validateOnce.Do(func() {
		validate = validator.New(validator.WithRequiredStructEnabled())
		validate.RegisterTagNameFunc(func(f reflect.StructField) string {
			name := strings.SplitN(f.Tag.Get("json"), ",", 2)[0]
			if name == "-" || name == "" {
				return f.Name
			}
			return name
		})
	})
	return validate
}

// MaxBodyBytes is the default JSON body limit (1 MiB).
const MaxBodyBytes int64 = 1 << 20

// DecodeAndValidate decodes the JSON request body into dst and runs struct
// validation. Malformed JSON yields 400, failed validation yields 422 with
// per-field details.
func DecodeAndValidate(r *http.Request, dst any) error {
	if err := Decode(r, dst); err != nil {
		return err
	}
	return Validate(dst)
}

// Decode decodes the JSON body into dst without validating it.
func Decode(r *http.Request, dst any) error {
	if ct := r.Header.Get("Content-Type"); ct != "" && !strings.HasPrefix(ct, "application/json") {
		return apierr.New(apierr.CodeUnsupportedType, http.StatusUnsupportedMediaType,
			"Content-Type must be application/json")
	}

	dec := json.NewDecoder(io.LimitReader(r.Body, MaxBodyBytes+1))
	dec.DisallowUnknownFields()

	if err := dec.Decode(dst); err != nil {
		return decodeError(err)
	}
	if dec.More() {
		return apierr.BadRequest("request body must contain a single JSON object")
	}
	return nil
}

// Validate runs struct validation on an already populated value.
func Validate(dst any) error {
	if err := Validator().Struct(dst); err != nil {
		var invalid *validator.InvalidValidationError
		if errors.As(err, &invalid) {
			return apierr.Internal(err, "invalid validation target")
		}
		var verrs validator.ValidationErrors
		if errors.As(err, &verrs) {
			details := make([]apierr.FieldError, 0, len(verrs))
			for _, fe := range verrs {
				details = append(details, apierr.FieldError{
					Field:   fe.Field(),
					Message: validationMessage(fe),
				})
			}
			return apierr.Validation("validation failed", details...)
		}
		return apierr.Validation("validation failed")
	}
	return nil
}

func decodeError(err error) error {
	var syntaxErr *json.SyntaxError
	var typeErr *json.UnmarshalTypeError
	var maxErr *http.MaxBytesError

	switch {
	case errors.As(err, &syntaxErr):
		return apierr.BadRequest(fmt.Sprintf("malformed JSON at offset %d", syntaxErr.Offset))
	case errors.As(err, &typeErr):
		field := typeErr.Field
		if field == "" {
			field = "body"
		}
		return apierr.Validation("invalid field type", apierr.FieldError{
			Field:   field,
			Message: "must be of type " + typeErr.Type.String(),
		})
	case errors.As(err, &maxErr):
		return apierr.New(apierr.CodePayloadTooLarge, http.StatusRequestEntityTooLarge, "request body too large")
	case errors.Is(err, io.EOF):
		return apierr.BadRequest("request body must not be empty")
	case strings.HasPrefix(err.Error(), "json: unknown field "):
		field := strings.Trim(strings.TrimPrefix(err.Error(), "json: unknown field "), `"`)
		return apierr.Validation("unknown field", apierr.FieldError{Field: field, Message: "unknown field"})
	default:
		return apierr.BadRequest("malformed JSON body")
	}
}

func validationMessage(fe validator.FieldError) string {
	switch fe.Tag() {
	case "required":
		return "required"
	case "email":
		return "must be a valid email"
	case "uuid", "uuid4":
		return "must be a valid uuid"
	case "min":
		return "must be at least " + fe.Param()
	case "max":
		return "must be at most " + fe.Param()
	case "len":
		return "must have length " + fe.Param()
	case "oneof":
		return "must be one of: " + fe.Param()
	case "gt":
		return "must be greater than " + fe.Param()
	case "gte":
		return "must be greater than or equal to " + fe.Param()
	case "lt":
		return "must be less than " + fe.Param()
	case "lte":
		return "must be less than or equal to " + fe.Param()
	case "e164":
		return "must be a valid E.164 phone number"
	case "url":
		return "must be a valid url"
	default:
		return "invalid value (" + fe.Tag() + ")"
	}
}
