package notify

import "strings"

// Default channel matrix of TZ A§19. It applies when a company has no
// notification_settings row for the alert type.
var defaultChannels = map[string][]string{
	AlertHOSWarning:          {ChannelPush},
	AlertHOSViolation:        {ChannelPush, ChannelEmail},
	AlertRouteAssigned:       {ChannelPush},
	AlertRouteReassigned:     {ChannelPush},
	AlertRouteCompleted:      {ChannelPush},
	AlertRouteNotCompleted:   {ChannelPush},
	AlertDVIRDefects:         {ChannelPush, ChannelEmail},
	AlertDVIRCritical:        {ChannelPush, ChannelEmail, ChannelSMS},
	AlertLogEditRequest:      {ChannelPush},
	AlertLogEditResolved:     {ChannelPush},
	AlertUncertifiedLog:      {ChannelPush},
	AlertUnidentifiedDriving: {ChannelPush, ChannelEmail},
	AlertELDDisconnected:     {ChannelPush},
	AlertELDMalfunction:      {ChannelPush, ChannelEmail},
	AlertMaintenanceUpcoming: {ChannelPush, ChannelEmail},
	AlertMaintenanceOverdue:  {ChannelPush, ChannelEmail},
	AlertChatMessage:         {ChannelPush},
	AlertSubscriptionExpires: {ChannelEmail},
	AlertExportReady:         {ChannelPush, ChannelEmail},
	AlertExportFailed:        {ChannelPush, ChannelEmail},
}

// DefaultChannels returns the TZ A§19 default channels of an alert type.
func DefaultChannels(alertType string) []string {
	def, ok := defaultChannels[alertType]
	if !ok {
		return []string{ChannelPush}
	}
	out := make([]string, len(def))
	copy(out, def)
	return out
}

// IsMandatoryPush reports whether push may not be switched off for this alert
// type. Q89: a user may mute anything except the hos_* and eld_* families,
// because those are safety and compliance alerts.
func IsMandatoryPush(alertType string) bool {
	return strings.HasPrefix(alertType, "hos_") || strings.HasPrefix(alertType, "eld_")
}

// ResolveChannels merges the configured channels with the mandatory ones and
// always adds the in-app inbox. The result is de-duplicated and ordered like
// AllChannels so the stored notifications.channels array is stable.
func ResolveChannels(alertType string, configured []string) []string {
	set := make(map[string]struct{}, len(configured)+2)
	for _, c := range configured {
		c = strings.ToLower(strings.TrimSpace(c))
		if IsChannel(c) {
			set[c] = struct{}{}
		}
	}
	if IsMandatoryPush(alertType) {
		set[ChannelPush] = struct{}{}
	}
	set[ChannelInApp] = struct{}{}

	out := make([]string, 0, len(set))
	for _, c := range AllChannels {
		if _, ok := set[c]; ok {
			out = append(out, c)
		}
	}
	return out
}
