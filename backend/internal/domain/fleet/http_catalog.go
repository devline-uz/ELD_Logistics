package fleet

import (
	"net/http"
	"strings"

	"github.com/devline/onebook-eld/internal/domain/fleet/dto"
	"github.com/devline/onebook-eld/internal/httpx"
)

func catalogFilter(r *http.Request) (CatalogFilter, httpx.Page, error) {
	page, err := httpx.ParsePagination(r)
	if err != nil {
		return CatalogFilter{}, page, err
	}
	return CatalogFilter{
		Search: strings.TrimSpace(r.URL.Query().Get("search")),
		Limit:  page.Limit(),
		Offset: page.Offset(),
	}, page, nil
}

// listTrailers godoc
//
//	@Summary      List trailers
//	@Tags         trailers
//	@Produce      json
//	@Param        page      query  int     false  "Page number"   default(1)
//	@Param        per_page  query  int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Param        search    query  string  false  "Matches the trailer number"
//	@Success      200  {object}  dto.TrailerListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "trailers.read"
//	@Router       /trailers [get]
func (m *Module) listTrailers(w http.ResponseWriter, r *http.Request) {
	f, page, err := catalogFilter(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	rows, total, err := m.svc.ListTrailers(r.Context(), f)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, rows, page.Meta(total))
}

// createTrailer godoc
//
//	@Summary      Create trailer
//	@Description  `(company_id, number)` is unique among rows that are not soft deleted.
//	@Tags         trailers
//	@Accept       json
//	@Produce      json
//	@Param        Idempotency-Key  header  string             false  "Replay protection key"
//	@Param        body             body    dto.CatalogCreate  true   "Trailer payload"
//	@Success      201  {object}  dto.TrailerEnvelope
//	@Failure      400  {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      409  {object}  dto.ErrorResponse  "UNIQUE_VIOLATION"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "trailers.create"
//	@Router       /trailers [post]
func (m *Module) createTrailer(w http.ResponseWriter, r *http.Request) {
	var in dto.CatalogCreate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.CreateTrailer(r.Context(), in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusCreated, out)
}

// getTrailer godoc
//
//	@Summary      Get trailer
//	@Description  Cross-tenant identifiers answer 404, never 403.
//	@Tags         trailers
//	@Produce      json
//	@Param        id   path      string  true  "Trailer id"
//	@Success      200  {object}  dto.TrailerEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "trailers.read"
//	@Router       /trailers/{id} [get]
func (m *Module) getTrailer(w http.ResponseWriter, r *http.Request) {
	id, err := pathUUID(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.GetTrailer(r.Context(), id)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// updateTrailer godoc
//
//	@Summary      Update trailer
//	@Tags         trailers
//	@Accept       json
//	@Produce      json
//	@Param        id    path      string             true  "Trailer id"
//	@Param        body  body      dto.CatalogUpdate  true  "Fields to change"
//	@Success      200  {object}  dto.TrailerEnvelope
//	@Failure      400  {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "UNIQUE_VIOLATION"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "trailers.update"
//	@Router       /trailers/{id} [patch]
func (m *Module) updateTrailer(w http.ResponseWriter, r *http.Request) {
	id, err := pathUUID(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.CatalogUpdate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.UpdateTrailer(r.Context(), id, in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// deleteTrailer godoc
//
//	@Summary      Delete trailer
//	@Description  Soft delete; the number becomes reusable.
//	@Tags         trailers
//	@Produce      json
//	@Param        id   path  string  true  "Trailer id"
//	@Success      204  "No Content"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "RESOURCE_IN_USE"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "trailers.delete"
//	@Router       /trailers/{id} [delete]
func (m *Module) deleteTrailer(w http.ResponseWriter, r *http.Request) {
	id, err := pathUUID(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if err := m.svc.DeleteTrailer(r.Context(), id); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteNoContent(w)
}

// listDocs godoc
//
//	@Summary      List shipping documents
//	@Tags         shipping-documents
//	@Produce      json
//	@Param        page      query  int     false  "Page number"   default(1)
//	@Param        per_page  query  int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Param        search    query  string  false  "Matches the document number"
//	@Success      200  {object}  dto.ShippingDocumentListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "shipping_documents.read"
//	@Router       /shipping-documents [get]
func (m *Module) listDocs(w http.ResponseWriter, r *http.Request) {
	f, page, err := catalogFilter(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	rows, total, err := m.svc.ListDocs(r.Context(), f)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, rows, page.Meta(total))
}

// createDoc godoc
//
//	@Summary      Create shipping document
//	@Description  `(company_id, number)` is unique among rows that are not soft deleted.
//	@Tags         shipping-documents
//	@Accept       json
//	@Produce      json
//	@Param        Idempotency-Key  header  string             false  "Replay protection key"
//	@Param        body             body    dto.CatalogCreate  true   "Shipping document payload"
//	@Success      201  {object}  dto.ShippingDocumentEnvelope
//	@Failure      400  {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      409  {object}  dto.ErrorResponse  "UNIQUE_VIOLATION"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "shipping_documents.create"
//	@Router       /shipping-documents [post]
func (m *Module) createDoc(w http.ResponseWriter, r *http.Request) {
	var in dto.CatalogCreate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.CreateDoc(r.Context(), in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusCreated, out)
}

// getDoc godoc
//
//	@Summary      Get shipping document
//	@Description  Cross-tenant identifiers answer 404, never 403.
//	@Tags         shipping-documents
//	@Produce      json
//	@Param        id   path      string  true  "Shipping document id"
//	@Success      200  {object}  dto.ShippingDocumentEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "shipping_documents.read"
//	@Router       /shipping-documents/{id} [get]
func (m *Module) getDoc(w http.ResponseWriter, r *http.Request) {
	id, err := pathUUID(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.GetDoc(r.Context(), id)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// updateDoc godoc
//
//	@Summary      Update shipping document
//	@Tags         shipping-documents
//	@Accept       json
//	@Produce      json
//	@Param        id    path      string             true  "Shipping document id"
//	@Param        body  body      dto.CatalogUpdate  true  "Fields to change"
//	@Success      200  {object}  dto.ShippingDocumentEnvelope
//	@Failure      400  {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "UNIQUE_VIOLATION"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "shipping_documents.update"
//	@Router       /shipping-documents/{id} [patch]
func (m *Module) updateDoc(w http.ResponseWriter, r *http.Request) {
	id, err := pathUUID(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.CatalogUpdate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.UpdateDoc(r.Context(), id, in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// deleteDoc godoc
//
//	@Summary      Delete shipping document
//	@Description  Soft delete; the number becomes reusable.
//	@Tags         shipping-documents
//	@Produce      json
//	@Param        id   path  string  true  "Shipping document id"
//	@Success      204  "No Content"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "RESOURCE_IN_USE"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "shipping_documents.delete"
//	@Router       /shipping-documents/{id} [delete]
func (m *Module) deleteDoc(w http.ResponseWriter, r *http.Request) {
	id, err := pathUUID(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if err := m.svc.DeleteDoc(r.Context(), id); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteNoContent(w)
}
