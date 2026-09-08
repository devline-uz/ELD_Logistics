package server

import (
	"net/http"

	"github.com/devline/onebook-eld/internal/apierr"
)

func errNotFound() error {
	return apierr.New(apierr.CodeNotFound, http.StatusNotFound, "endpoint not found")
}

func errMethodNotAllowed() error {
	return apierr.New(apierr.CodeBadRequest, http.StatusMethodNotAllowed, "method not allowed")
}

func errUnavailable(component string, err error) error {
	return apierr.Wrap(err, apierr.CodeUnavailable, http.StatusServiceUnavailable,
		component+" is unavailable")
}
