# Managing mobility in ad-hoc
In ad-hoc networks we can recognize different goals to achieve:

- Quickly adaptation to topology changes
- No centralization
- Loop free routing
- Load balancing among different routes in case of congestion
- Supporting asymmetric communications
- Low overhead and memory requirements
- Security

The proactive approach attempt to maintain consistent, up to date routing information from each node to every other node in the network.
In the reactive one the route to a destination is discovered only when it's desired by the source node.

In the following discussion we will represent each terminal/station as a node in a graph, a directed edge from a node to another represents the faculty of a source to directly send packets to a destination.
Assuming the same radio range for all the nodes and a circular transmission area we can state the links are symmetric, and so we can use an undirected graph.

## Dynamic Source Routing (DSR)
The DSR is a protocol proposed in 1994 to quickly react to changes in the network without a centralization point and with a low overhead.
The protocol is based on the following assumptions:

- The nodes are cooperative, all of them want to participate fully in the network protocol and will forward packets for other nodes.
- The network diameter is small, the number of hops needed to travel from any node at the extreme edge of the network is small (5-10) but greater than 1.
- Corrupted packets can be recognized and discarded by their destination.
- The nodes may move in the network at any time without notice, but their speed is moderate with respect to the packet transmission latency, meaning that in general the topology change should be infrequent and unlikely to occur during the route discovery.

The route discovery (RD) is the mechanism by which a node wishing to send a packet obtains a route to the destination if not already present.
The other basic mechanism of DSR is the route maintenance (RM) by which the source route is able to detect that topology has changed and so that the route for the required destination is no longer available.

S searches for a source route R to D in its route cache, if it finds it S places R in the header of the new packet and sends it, otherwise it start a route discovery protocol sending a route request (RREQ) to all the nodes it can reach directly via local broadcast.
Each copy of the RREQ contains the unique IDs of the source and the destination, and the list of nodes through which the particular RREQ has been forwarded.

When a node receives the RREQ and it's not the target checks if it has already received, in that case it discards it, otherwise it appends its unique ID and local broadcast it.
When the target receives the RREQ returns a reply to S (RREP) including a copy of the accumulated route record, if the destination has not a path to the original source it has to start a route discovery combined with the RREP, this is obviously not needed if all the links are bidirectional.
The target can receive possibly different paths, it can independently chose one of them based on latency, number of hops, energy levels or other metrics.

While the packets to be sent wait for a route discovery to be completed they are kept in a send buffer, they can expire and be deleted after a timeout, also they can be evicted with some policy (FIFO) to prevent send buffer from overflowing.
Also the source node occasionally starts a route discovery, using exponential backoff to delay further route discoveries for the same destination to avoid overflowing the network in case the target is unreachable.

When sending a packet along a route each node in the route is responsible of the receipt of the packet at the following hop in the route.
If a device detects that a route link is down a route error is returned to the sender stating the status of the link, the sender then removes all the routes containing the broken link from the cache, also the route error is reported to the upper layers.

A possible improvement is for all the nodes in the network to cache not only the results of a route discovery procedure, but also the accumulated routes in a route request/reply and the sources in a data packet.
Also it's possible to reply to route request using cached routes, sharing the internal knowledge of the node without local broadcasting the request up to the target.
In this case many nodes may have a route, so to avoid collisions and to favour shortest routes a node must wait for a random period before replying to the route request, this period is computed as following:

$$
D = L(H-1+R)
$$

Where $H$ is the hop-length of the route to be returned, $R$ is a random number between 0 and 1, and $L$ is a constant at least twice the maximum wireless link propagation delay.

Further improvements could include limit the time-to-live of RREQ, automatically cut out intermediate hops that are no longer needed in a route and cache broken links to prevent their use in other routes.

The DSR packets are standard IP packets that uses special flags in the option header.

## Ad-Hoc On-Demand Distance Vector (AODV)
AODV is a project proposed in 1994 with the same goals of DSR, but the also integrates unicast, multicast and broadcast messages.
The assumptions are similar to the ones for DSR, the nodes must be cooperative but also the links must be bidirectional, this could be enforced by pruning unidirectional links.

The protocol uses one route table for unicast and one for multicast.
Each table contains at most one route for each destination, maintaining the next hop and a precursor.
If the entry is not used within a lifetime timer it is removed.

Each node also maintains a monotonic sequence number, this value is increased each time a node detects a change in its neighborhood.
Each multicast group maintains a separate sequence number.

When a source originates a packet for a destination non present in it's routing table it broadcasts a route discovery message RREQ and sets a timer to wait for a reply.
Since flooding the network with RREQ could be expensive a growing TTL is used by the source to try different route requests up to a fixed constant maximum, when a route is established the distance to the destination is recorded to set the initial TTL in the next route discovery for the same destination.
The RREQ contains:

- IP address of source and its current sequence number, which is incremented
- IP address of the destination and its last known sequence number
- Broadcast ID, which is incremented
- Hop count initially set to zero

When an intermediate node, known also as rely, receives a RREQ checks if it has already received it by comparing both IP source and broadcast id with a cache of all received RREQ in the near past.
If the request is new it is processed by inserting in its routing table the reverse route for the source node, to be able to forward to it a RREP if it is received.

A rely node is able to directly respond to a RREQ if it contains a unexpired entry for the destination in its route table with a sequence number at least great as the one included in the RREQ, this is needed to avoid loops.
If a rely node is not able to respond to RREQ it increments the hop count field in the RREQ and broadcasts the packet to its neighbors.

When the RREQ finally reaches the destination a RREP is generated, containing more or less the same information of the RREQ, but also the route lifetime and the sequence number of the destination which is incremented by one.

If a rely node receives a RREP sets up a forward path for the destination in its route table and forwards the RREP by updating the hop count with its distance from the destination.

Each node periodically sends to its neighbors special `HELLO` packets to inform its neighbors of its presence in the neighborhood, technically this packages are unsolicited RREP with TTL equal to 1 to prevent resend.

For what concerns route maintenance each node back-propagates RERR packets to all its precursors, marking the unreachable destination with an infinite distance.

### Multicast
Each multicast group has a leader and a bidirectional multicast tree, a message to a group is routed using the tree starting from the first node in the group reached.
A multicast group has a sequence number maintained by the leader.

When a node wishes to join a group or to send data to a group it starts a route request including the known sequence number for the group.

## Dynamic Manet On Demand Routing (DYMO)
The DYMO protocol has been proposed in 2011 and tries to simplify AODV and merge the features of both DSR and AODV.

The assumptions of the protocol are the same already seen: cooperative nodes, bidirectional symmetric links, recognition of corrupted packets and slow mobility nodes.

In DYMO route discovery and route maintenance work in similar way as in AODV, using sequence numbers to prevent loops.
Like DSR instead `HELLO` packets are not used, favoring timers, and RREQ and RREP messages carry information on all intermediate nodes, and are used for creating table entries for all intermediate nodes, not only for source and destination as in AODV.

The sequence numbers are incremented when a source node, generates a new RREQ or when a destination node answers with a RREP, also when an intermediate node adds its information in a routing packet.
Also when a node is rebooted it must not set its sequence number to 0, since this could produce loops due to old entries in other node's tables, so the sequence number should be kept in persistent memory if possible.

