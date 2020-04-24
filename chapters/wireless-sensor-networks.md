# Wireless sensor networks
A Wireless Sensor Network is a very characteristic network where each of its nodes is a small autonomous sensor with low power and low cost system.

Of the many issues in the WSN design one of the most important is the energy consumption, since sensors are battery-powered and need efficient solutions.

The wireless communication, that is use of a radio, is obviously costly and so the radio should be turned off as much as possible, also the processor should be turned off when not used.
In any case turning on and off consumes power as well, so it's useful to find a balance between this two states.

The activities of a sensor are mostly repetitive: sense, process, store, transmit and receive.
Each sensor alternates a period of activity and a period of inactivity, this defines a duty cycle.

The energy cost of any component $\mu$ can be computed as:

$$
E_{\mu} = c_{\mu}^{full} \cdot dc_{\mu} + c_{\mu}^{idle} \cdot (1-dc_{\mu})
$$

The total energy cost is the sum over all the components $E = \sum_\mu E_\mu$.
The battery capacity at cycle $n$ is defined as $B_n = B_{n-1} (1-\epsilon) - E$, where $L$ or $\epsilon$ is the loss of capacity per cycle. ???
By solving the recurrence equation we are able to obtain the lifetime of the device for $n$ s.t. $B_n = B_0 (1-\epsilon)^{n-1} + \frac{E((1-\epsilon)^n -1)}{L} = 0$.

So it seems that reducing the duty cycle is a good solution to reduce the energy consumption and improve the efficiency, it should be noticed that while turning off the processor is a local decision, turning off the radio requires a global decision, since when the node is down the sensor can't contribute to the network, that as we already have seen is a requirement of multiple cooperative routing algorithms.
The decisions about the state off the radio are usually directly managed by the MAC protocols for the WSN.

## Multi-hop communication and mobility
Assuming a wireless channel model without interference we can define $P_A$ as the power used by node A to send a message and $P^r_B$ as the intensity of the received signal at node B, given by the ratio of the sending power and the path loss, proportional to the distance of the nodes.
We also define a threshold $\beta$ such that for node B to correctly receive a message it must hold $P^r_B > \beta$.
When speaking of multi-hop communication the overall path loss can be computed by summing the distances or using simple trigonometric functions, for instance two short links are always better than a wider one, given that `GIGACONDITION FROM SLIDE 16`.

Anyway the model without interference is unrealistic, so we redefine the correct transmission of a message from A to B iff.

$$
\forall C . d(C,B) \geq (1+\Delta)d(A,B)
$$

Where $\Delta$ is a constant that depends on the features of the radio and all the nodes C are the nodes that transmits simultaneously.
For this reason is always better to use multiple short links than a wider one, since in this way we can allow other communications of other sensors.
This can be proved by using Holder inequality.

## MAC Protocols
In a WSN the use of MAC protocols is not confined to media arbitration, but it is also useful for energy efficiency.
The objectives are to reduce the radio duty cycle and to maintain network connectivity, so the tradeoff is between the energy and the latency or the bandwidth.

The synchronization of the nodes is a desirable condition since if the nodes are synchronized they can turn on the radios simultaneously.

### S-MAC
This protocol exploits local node synchronization, alternating listen and sleep periods when the sensor is not able to detect any incoming message.

Adjacent sensors synchronize their listen periods by means of periodical local broadcasts of `SYNC` packets that contain the schedule of the sensor.
If a sensor detects adjacent sensors with a predefined listen period it uses the same period, otherwise it chooses its own period advertising it to the neighbors.

Since a sensor can receive a packet only in its listen period, the sender may need to turn on its radio also outside its listen period, so it should know all the listen periods of its neighbors.
Before sending a packet the media is sensed, if busy it tries again in the next period, also the collision avoidance mechanism is based on RTS/CTS as in IEEE 802.11.

While travelling across a multihop path a packet may have to wait in the worst case for the listen period of each intermediate node, this is mitigated by the fact that hopefully a certain number of sensors will converge towards the same schedule.
It should be noticed that in any case depending on the topology it may be impossible for a sensor to have a listen period compatible with all its neighbors.

### B-MAC
In B-MAC a node can send whenever it wants using packets that contain a very long preamble in the header.
The receiver activates its radio periodically to check if there is a preamble on the air, this activity is called preamble sampling and it is based on a low-power-listening mode.
Obviously the preamble should be longer than the sleep period, this costs more in transmission but save energy in reception since the preamble sampling can be very short and cheap.

We can model the energy consumption in Joule spent in $t$ seconds for both the sender and the receiver and consequently the lifetime.

This simple and transparent protocol may turn to be expensive in the long run.

### X-MAC
This protocol is an evolution of B-MAC aimed to reduce the impact of long preambles by inserting the ID of the receiver so that it is able to check if it's the actual receiver and also to interrupt the preamble to request the packet.
This second feature is realized since the transmitter fragments the preamble and waits for an acknowledgment from the receiver for a short timer after each fragment.

### Polling
Polling is an asymmetrical MAC technique that is combined with synchronization.

One master node issues periodic beacons, while several slaves can keep the radio off whenever they want.
If the master receives a message for a slave it stores the message and advertises it in the beacon, when the slave turns on the radio it waits for the beacon and recognizing that there is a pending message it request it to the master.

## Network Protocols
Sensor networks are mostly data centric, so the identification of a node is less meaningful than its capabilities, nonetheless traditional routing protocols are not practical because of the large routing tables and the size of packet headers.

Because of this reasons it's important to use data centric routing protocols that are able to aggregate informations and are location aware being able to manage both the implosion and the overlap problem.

### Directed diffusion
The directed diffusion protocol has been presented in the year 2000 as a coordination protocol to perform distributed sensing of environmental phenomena.
The sensor network is programmed to respond to location and movement-aware queries.

All the data generated by sensors are named by attribute-value pairs.
The sink disseminates a sensing task in the network as an interest for named data.
The dissemination of interests sets up gradients.
Data matching the interest flow towards the sink along multiple paths.
The sink reinforces one, or a small number of these paths.
The directed diffusion protocol works also in presence of multiple sinks.

Interests are named by a sequence of attribute-value pairs that describe the task, for example the type of data requested, the interval of events, the duration of the whole sensing request and the region of interested sensors.
Also the data sent in response to the interest is also named using a similar naming scheme.

The interests are periodically generated by the sink, the first broadcast is exploratory while the following ones are refreshes of the same interest, this is necessary because dissemination of interests is not reliable.
The nodes receiving an interest may forward the interest to a subset of neighbors.
The node from which an interest has been received is called a gradient, it should be noticed that the same interest could be received by multiple nodes.
A gradient is associated to a direction and a data rate and they are used to route data matching the interest towards the sink.

Each node preserves in an internal cache the received interest, possibly aggregating them.
The interests in the cache expire when the duration time is elapsed.

When a sensor detects an event matching with an interest in cache starts sampling the event at the largest sampling rate of the corresponding gradients.
The sensor sends sampled data to the neighbors interested in the event, by eventually lowering the rate according to the request of the gradient.
The neighbors forward the data if and only if a corresponding interest, with a gradient, is still in the cache.

The reinforcement is used when the sink starts receiving data matching an exploratory interest from a sensor.
The sink reinforces the given sensor to improve the quality of received data, exploratory interests usually have a low sampling rate, reinforces of an interest with higher sampling rate.

The implicit assumption of directed diffusion is that the overall system can survive to lost messages, considering the they will flow constantly.

The protocol can be easily represented using a two-state machine, and it's suitable for implementation on low-end devices.
It's a scalable and robust protocol that results to be effective in applications that do not require complex data aggregation/preprocessing.

This tree structure constructed by the sink is scalable as we already mentioned but it's not completely fair for what concerns power consumption.
In a grid-connected network the nodes closer to the sink are those that consume more energy.
Also in an arbitrary connected network bottlenecks are common, especially between nodes that are close to sink.

### Greedy Perimeter Stateless Routing (GPSR)
This protocol tries to overcome the limitations of directed diffusion and of other similar protocols, providing arbitrary node-to-node routing and assuming limited resources and communication overhead.
The protocol is scalable since there is no use for route discovery and few control packets are used.

The nodes in the network must be aware of their position and of the position of their neighbors in a two dimensional space.
When sending a message the source knows the coordinate of the destination, so packet headers contain the destination coordinate.

GPSR actually comprises two different modes: Greedy forwarding and Perimeter forwarding.

In greedy forwarding, considering a packet with destination D, the forwarding node x select as next hop a neighbor y such that y is closer to D than x and among the neighbors y is the closest to the destination.
Greedy forwarding fails if the packets encounters a void, that is the actual node is closest to the destination but it can't reach it.

Perimeter mode forwarding is used when greedy forwarding fails, routing around the void using a rule (usually Right-Hand-Rule RHR) to define rotation order, exploring the edges of the polygon enclosing the void.

The graph of the WSN is a non-planar embedding of a graph, so edges may cross and the RHR may take a degenerate tour that does not trace the boundary of a closed polygon.
For this reason, GPSR applies the perimeter mode to a planar graph P obtained from the Relative Neighborhood Graph and the Gabriel Graph of the original non-planar graph G.
If G is connected then P is connected, also P is obtained from G by removing edges and is computed with a distributed algorithm executed along with the perimeter mode packet forwarding.

The greedy mode forwarding uses all the links in G, while the perimeter mode forwarding uses only the links in the planar graph P.

The relative neighborhood graph RNG of G is the set of all the edges s.t.

$$
(u,v) \in P iff. (u,v) \in G \land
d(u,v) \leq \max_{\forall w \in N(u) \cup N(v)} (d(u,w),d(w,v))
$$

The Gabriel Graph is similar but it regards only a circular area.

The GG keeps more links than RNG, and actually RNG is a subgraph of GG, anyway both are suitable to GPSR.

Should be improved the part about perimeter mode.

GPSR switches back to greed whenever it finds a node that is closer than the first one failing to the destination.

GPSR relies on updated information about the position of the neighbors because it needs a freshly planar version of the graph to avoid performance degradation.
Performing planarization at each topology change is not good since node may move within a node's transmission range, continuously changing the selection of links by GG or RNG.
A proactive approach is used: nodes periodically communicate their position to their neighbors.
This beacon is used to keep updated the list of neighbors and to force planarization when the line changes are excessive.

Planarization could fail due to unidirectional links caused for example by obstacles or because the assumption of unit disk graph does not hold anymore.
This could lead to possible loops.

One solution is to use bidirectional links to avoid loops, this is enforced by the mutual witness rule.
Even this can fail due to undetectable cross links, but there is another solution called Cross Link Detection Protocol, study that.

## Data-Centric Storage
In a wireless sensor network there is an important tradeoff between the transmission and the storage of the informations.
Once the user sends instructions to the nodes each node can either:

1. Send information to an external storage through the sink
2. Store information internally in a local storage
3. Use a data-centric storage

Let's define the asymptotic costs in terms of the number of nodes $n$, the cost for flooding a WSN is $O(n)$, while the cost for unicast in reasonably $O(\sqrt n)$.

If using an external storage for each single event the cost is $O(\sqrt n)$, because it accounts the transmission of each information to the sink.
Dealing with local storage the sensor does not incur in any communication cost, but the user should look for the information in the WSN, each query costs $O(n)$ and each reply $O(\sqrt n)$. 
Using data-centric storage the cost is $O(\sqrt n)$ to direct the information to a specific node and $O(\sqrt n)$ to send the response of the query to the sink.

### Geographic Hash Tables

## Physical and virtual coordinates

## Clustering in WSN

