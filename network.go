package openzwave

import (
	"github.com/ninjasphere/go-openzwave/NT"
)

const (
	MAX_NODES = 232 // max set by ZWave protocol
)

// represents a single Zwave network
type Network interface {
	Notifiable
	// the identifier of the home network
	GetHomeId() uint32
}

type network struct {
	homeId uint32
	nodes  map[uint8]*node
}

func newNetwork(homeId uint32) *network {
	return &network{homeId, make(map[uint8]*node)}
}

func (self *network) GetHomeId() uint32 {
	return self.homeId
}

func (self *network) Notify(api API, notification Notification) {
	notificationType := notification.GetNotificationType()
	switch notificationType.Code {

	// network level events
	case NT.DRIVER_READY:
	case NT.DRIVER_RESET:
		// reset network object to reset state
		self.reset()
		break

	// group associations
	case NT.GROUP:
		// not much to do here unless we end up needing to configure group configurations
		// in order to rescue a broken ninja device.
		unhandled(api, notification)
		break

	case NT.AWAKE_NODES_QUERIED:
	case NT.ALL_NODES_QUERIED_SOME_DEAD:
	case NT.ALL_NODES_QUERIED:
		unhandled(api, notification)
		break
		// move network into running state

	default:
		node := notification.GetNode()
		if node.GetId() < MAX_NODES {
			self.handleNodeEvent(api, notification, self.takeNode(notification))
		} else {
			unexpected(api, notification)
		}
	}
}

func (self *network) handleNodeEvent(api API, notification Notification, node Node) {

	notificationType := notification.GetNotificationType()
	switch notificationType.Code {
	case NT.NODE_NEW:
	case NT.NODE_ADDED:
	case NT.NODE_REMOVED:
	//
	// node level events
	//
	case NT.NODE_NAMING:
	case NT.NODE_PROTOCOL_INFO:
		// log the related information for diagnostics purposes
		break

	case NT.ESSENTIAL_NODE_QUERIES_COMPLETE:
	case NT.NODE_QUERIES_COMPLETE:
		// move the node into the initialized state
		// begin admission processing for the node
		break

	case NT.VALUE_ADDED:
	case NT.VALUE_REMOVED:
	case NT.VALUE_CHANGED:
	case NT.VALUE_REFRESHED:
		// update node state
		// generate a node changed event
		break

	// notifications
	case NT.NOTIFICATION:
		// network or node level events
		break

	default:

	}
}

func (self *network) reset() {
	self.nodes = make(map[uint8]*node)
}

func (self *network) takeNode(tmp Notification) Node {
	id := tmp.GetNode().GetId()
	n, ok := self.nodes[id]
	if !ok {
		n = tmp.(*notification).swapNodeImpl(nil).(*node)
		self.nodes[id] = n
	} else {
		tmp.(*notification).swapNodeImpl(n)
	}
	return n
}
