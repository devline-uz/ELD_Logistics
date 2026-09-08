package fleet

import (
	"net/http"

	"github.com/devline/onebook-eld/internal/domain/fleet/dto"
	"github.com/devline/onebook-eld/internal/httpx"
)

// listDevices godoc
//
//	@Summary      List ELD devices
//	@Description  Registered ELD hardware with its current unit, firmware and raised malfunction codes.
//	@Tags         eld-devices
//	@Produce      json
//	@Param        page             query  int     false  "Page number"   default(1)
//	@Param        per_page         query  int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Param        sort             query  string  false  "Sort field"  Enums(serial, vendor, status, created_at)
//	@Param        order            query  string  false  "Sort order"  Enums(asc, desc)
//	@Param        search           query  string  false  "Matches serial, vendor or model"
//	@Param        status           query  string  false  "Device status"  Enums(active, inactive, malfunction)
//	@Param        unit_id          query  string  false  "Unit filter (uuid)"
//	@Param        connection_type  query  string  false  "Connection type"  Enums(bluetooth, wifi, cellular, usb)
//	@Success      200  {object}  dto.EldDeviceListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "eld_devices.read"
//	@Router       /eld-devices [get]
func (m *Module) listDevices(w http.ResponseWriter, r *http.Request) {
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	sort, err := httpx.ParseSort(r, deviceSorts, httpx.Sort{Field: "serial", Order: "asc"})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	unitID, err := httpx.QueryUUID(r, "unit_id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	status, err := queryEnum(r, "status", dto.StatusActive, dto.StatusInactive, "malfunction")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	conn, err := queryEnum(r, "connection_type", dto.ConnBluetooth, dto.ConnWifi, dto.ConnCellular, dto.ConnUSB)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}

	devices, total, err := m.svc.ListDevices(r.Context(), DeviceFilter{
		Search:         queryText(r, "search"),
		Status:         status,
		UnitID:         unitID,
		ConnectionType: conn,
		Sort:           sort.Field,
		Order:          sort.Order,
		Limit:          page.Limit(),
		Offset:         page.Offset(),
	})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, devices, page.Meta(total))
}

// createDevice godoc
//
//	@Summary      Register an ELD device
//	@Description  `(company_id, serial)` is unique among rows that are not soft deleted. Q3.1 — wiring the device to an inactive unit answers 409.
//	@Tags         eld-devices
//	@Accept       json
//	@Produce      json
//	@Param        Idempotency-Key  header  string               false  "Replay protection key"
//	@Param        body             body    dto.EldDeviceCreate  true   "Device payload"
//	@Success      201  {object}  dto.EldDeviceEnvelope
//	@Failure      400  {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "UNIQUE_VIOLATION / INVALID_STATE"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "eld_devices.create"
//	@Router       /eld-devices [post]
func (m *Module) createDevice(w http.ResponseWriter, r *http.Request) {
	var in dto.EldDeviceCreate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.CreateDevice(r.Context(), in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusCreated, out)
}

// getDevice godoc
//
//	@Summary      Get ELD device
//	@Description  Cross-tenant identifiers answer 404, never 403.
//	@Tags         eld-devices
//	@Produce      json
//	@Param        id   path      string  true  "Device id"
//	@Success      200  {object}  dto.EldDeviceEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "eld_devices.read"
//	@Router       /eld-devices/{id} [get]
func (m *Module) getDevice(w http.ResponseWriter, r *http.Request) {
	id, err := pathUUID(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.GetDevice(r.Context(), id)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// updateDevice godoc
//
//	@Summary      Update ELD device
//	@Description  Partial update; omitted fields keep their stored value.
//	@Tags         eld-devices
//	@Accept       json
//	@Produce      json
//	@Param        id    path      string               true  "Device id"
//	@Param        body  body      dto.EldDeviceUpdate  true  "Fields to change"
//	@Success      200  {object}  dto.EldDeviceEnvelope
//	@Failure      400  {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "UNIQUE_VIOLATION"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "eld_devices.update"
//	@Router       /eld-devices/{id} [patch]
func (m *Module) updateDevice(w http.ResponseWriter, r *http.Request) {
	id, err := pathUUID(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.EldDeviceUpdate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.UpdateDevice(r.Context(), id, in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// deleteDevice godoc
//
//	@Summary      Delete ELD device
//	@Description  Soft delete; the open unit assignment is closed in the same transaction and the serial becomes reusable.
//	@Tags         eld-devices
//	@Produce      json
//	@Param        id   path  string  true  "Device id"
//	@Success      204  "No Content"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "RESOURCE_IN_USE"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "eld_devices.delete"
//	@Router       /eld-devices/{id} [delete]
func (m *Module) deleteDevice(w http.ResponseWriter, r *http.Request) {
	id, err := pathUUID(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if err := m.svc.DeleteDevice(r.Context(), id); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteNoContent(w)
}

// assignDeviceUnit godoc
//
//	@Summary      Wire an ELD device to a unit
//	@Description  Writes `eld_device_assignments` (from_at/to_at). A null `unit_id` detaches the device. One unit carries at most one active device (409 ALREADY_ASSIGNED) and Q3.1 forbids wiring to an inactive unit (409 INVALID_STATE).
//	@Tags         eld-devices
//	@Accept       json
//	@Produce      json
//	@Param        id               path    string                   true   "Device id"
//	@Param        Idempotency-Key  header  string                   false  "Replay protection key"
//	@Param        body             body    dto.EldDeviceAssignUnit  true   "Target unit"
//	@Success      200  {object}  dto.EldDeviceEnvelope
//	@Failure      400  {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "ALREADY_ASSIGNED / INVALID_STATE"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "eld_devices.assign_unit"
//	@Router       /eld-devices/{id}/assign-unit [post]
func (m *Module) assignDeviceUnit(w http.ResponseWriter, r *http.Request) {
	id, err := pathUUID(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.EldDeviceAssignUnit
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.AssignDeviceToUnit(r.Context(), id, in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}
