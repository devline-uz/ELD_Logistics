package ws

import (
	"context"
	"encoding/json"
	"log/slog"
	"time"

	"github.com/google/uuid"
	"github.com/redis/go-redis/v9"
)

// RedisChannel is the pub/sub channel every API node publishes hub traffic on.
// One channel is enough: the envelope carries company_id and each node filters
// locally, which keeps the number of Redis subscriptions constant.
const RedisChannel = "eld:ws"

// envelope is the cross node wire format. NodeID lets a node ignore its own
// messages, which it has already delivered locally.
type envelope struct {
	NodeID  uuid.UUID `json:"node_id"`
	Message Message   `json:"message"`
}

// Bridge fans hub messages out across API nodes over Redis pub/sub. It is the
// Publisher services depend on in a multi node deployment; the local hub is
// still written to directly so a Redis outage degrades to single node
// delivery instead of silence.
type Bridge struct {
	client  redis.UniversalClient
	hub     *Hub
	channel string
	nodeID  uuid.UUID
	log     *slog.Logger
}

// NewBridge builds the Redis fan-out. A nil client yields a bridge that only
// serves the local hub.
func NewBridge(client redis.UniversalClient, hub *Hub, log *slog.Logger) *Bridge {
	if log == nil {
		log = slog.Default()
	}
	return &Bridge{client: client, hub: hub, channel: RedisChannel, nodeID: uuid.New(), log: log}
}

// NodeID identifies this process in the pub/sub stream.
func (b *Bridge) NodeID() uuid.UUID { return b.nodeID }

// Publish implements Publisher: deliver locally first, then hand the message to
// the other nodes.
func (b *Bridge) Publish(ctx context.Context, msg Message) error {
	if msg.SentAt.IsZero() {
		msg.SentAt = time.Now().UTC()
	}
	if b.hub != nil {
		_ = b.hub.Publish(ctx, msg)
	}
	if b.client == nil {
		return nil
	}
	buf, err := json.Marshal(envelope{NodeID: b.nodeID, Message: msg})
	if err != nil {
		return err
	}
	// A failed fan-out must not fail the business operation that published it;
	// the caller logs and moves on.
	return b.client.Publish(ctx, b.channel, buf).Err()
}

// Run consumes the pub/sub stream until ctx is cancelled. Messages published by
// this node are skipped because Publish already delivered them.
func (b *Bridge) Run(ctx context.Context) error {
	if b.client == nil || b.hub == nil {
		<-ctx.Done()
		return ctx.Err()
	}
	sub := b.client.Subscribe(ctx, b.channel)
	defer func() { _ = sub.Close() }()

	ch := sub.Channel()
	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case raw, ok := <-ch:
			if !ok {
				return nil
			}
			var env envelope
			if err := json.Unmarshal([]byte(raw.Payload), &env); err != nil {
				b.log.WarnContext(ctx, "ws: malformed fan-out envelope", slog.String("error", err.Error()))
				continue
			}
			if env.NodeID == b.nodeID {
				continue
			}
			_ = b.hub.Publish(ctx, env.Message)
		}
	}
}

// Close releases the Redis resources owned by the bridge. The client itself is
// owned by the caller.
func (b *Bridge) Close() error { return nil }
