package metrics

import (
	"context"

	"github.com/hibiken/asynq"
)

// AsynqQueueSource adapts *asynq.Inspector to QueueStatsSource so the worker
// can publish queue depth and lag without this package depending on the wiring.
type AsynqQueueSource struct {
	inspector *asynq.Inspector
}

// NewAsynqQueueSource wraps an inspector. A nil inspector yields no stats.
func NewAsynqQueueSource(inspector *asynq.Inspector) *AsynqQueueSource {
	return &AsynqQueueSource{inspector: inspector}
}

// QueueStats implements QueueStatsSource.
func (s *AsynqQueueSource) QueueStats(_ context.Context) ([]QueueStat, error) {
	if s == nil || s.inspector == nil {
		return nil, nil
	}
	queues, err := s.inspector.Queues()
	if err != nil {
		return nil, err
	}
	out := make([]QueueStat, 0, len(queues))
	for _, q := range queues {
		info, err := s.inspector.GetQueueInfo(q)
		if err != nil {
			// One unreadable queue must not hide the others.
			continue
		}
		out = append(out, QueueStat{
			Queue:     q,
			Size:      info.Size,
			Pending:   info.Pending,
			Active:    info.Active,
			Scheduled: info.Scheduled,
			Retry:     info.Retry,
			Latency:   info.Latency,
		})
	}
	return out, nil
}
