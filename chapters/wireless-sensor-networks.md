# Wireless sensor networks
A Wireless Sensor Network is a peculiar ad-hoc wireless network characterized by the fact that its nodes are small autonomous sensors with low power. 
The sensors are equipped with little amounts of memory storage and computational power, other than the radio transceivers needed to perform communication.

## Energy consumption
Of the many issues in the WSN design one of the most important is the energy consumption, since the sensors are battery-powered and so they need efficient solutions.
The wireless communication is obviously costly and so the radio should be turned off as much as possible, this should be applied to all the components in a sensor.
In any case switching on and off the components consumes power as well, so a balance must be found.

The activities of a sensor are mostly repetitive: sense, process, store, transmit and receive.
Each sensor alternates a period of activity and a period of inactivity, this defines a duty cycle.

Formally the duty cycle of a component $\mu$ is the fraction of the period in which the component is active.

$$
\sum_{s \in S_\mu} dc_\mu^s = 1
$$

The energy cost of any component $\mu$ can be computed as:

$$
E_{\mu} = \sum_{s \in S_\mu} c_{\mu}^{s} \cdot dc_{\mu}^{s}
$$

The total energy cost for the sensor is obtained as: 

$$
E = \sum_\mu E_\mu
$$

Given an initial capacity $B_0$ for the battery of the sensor it's possible to compute the ideal lifetime of a sensor as:

$$
n = \frac{B_0}{E}
$$

Actually the battery is an object that loses its capacity during the time, so also the battery leaks must be formalized:

$$
n = \frac{B_0 - L(n)}{E}
$$

Given that the overall battery leaks $L$ also depends on the lifetime the formulation of a problem leads to the following recurrence equation, where the term $\epsilon$ represents the leaks per cycle and $\gamma = 1-\epsilon$ is used to simplify the notation.

$$
B_n = B_{n-1} \cdot ( 1 - \epsilon ) - E \\
$$
$$
B_n = B_0 \cdot \gamma^n - E \cdot \frac{\gamma^n-1}{\gamma-1}
$$

The lifetime $n$ is so the first value for which $B_n \leq 0$.

Reducing the duty cycle is a good solution to reduce the energy consumption and improve the efficiency.
Anyway it should be noticed that while turning off the processor is a local decision, turning off the radio requires a global decision, since when the node is down the sensor can't contribute to the network, that as we already have seen is a requirement of multiple cooperative routing algorithms.
Because of this the decisions about the state of the radio are usually directly managed by the MAC protocols for the WSN.

## Multi-hop communication and mobility
Assuming a wireless channel model without interference we can define $P_A$ as the power used by node A to send a message and $P^r_B$ as the intensity of the received signal at node B and $\beta$ as the minimal intensity to correctly receive the message.

$$
P_B^r = \frac{P_A}{PL(A,B)}
$$
$$
P^r_B > \beta
$$

The path loss $PL$ is assumed to be proportional to $d(A,B)^\alpha$, where $d$ is the euclidean distance between the nodes and $\alpha$ is a constant depending on the environment, normally assumed in the range $[2,6]$.

Assuming $\alpha = 2$ and using the law of cosines it's possible to state that $D(A,B)^2 > D(A,C)^2 + D(C,D)^2$ when $\gamma \geq \frac{\pi}{2}$, or equivalently when the node `C` is in the circle of the figure \ref{fig:path_loss}.
Because of this two short links should be preferred when sending a message from `A` to `B`.

![\label{fig:path_loss}](assets/path_loss.png)

![\label{fig:interference}](assets/interference.png)

Another possible problem in multi-hop communication is given by the interferences.
Assume that the node `A` sent a packet to node `B`, the packet is correctly received if and only if for any other node `C` that transmits simultaneously:

$$
d(C,B) \geq (1+\Delta)d(A,B)
$$

Where $\Delta$ is a constant that depends on the features of the radio.

For this reason in scenario like the one in figure \ref{fig:interference} is always better to use multiple short links than a wider one, since in this way we can allow other communications of other sensors.
This can be proved by using Hölder inequality.

## MAC Protocols
In a WSN the use of MAC protocols is not confined to media arbitration, but it is also useful for energy efficiency.
The objectives are to reduce the radio duty cycle and to maintain network connectivity, so the tradeoff is between the energy consumption of each sensor and the performances of the whole network.

### S-MAC
This protocol exploits local node synchronization, alternating listen and sleep periods when the sensor is not able to detect any incoming message.
The synchronization of the nodes is a desirable condition since if the nodes are synchronized they can turn on the radios simultaneously.

Adjacent sensors synchronize their listen periods by means of periodical local broadcasts of `SYNC` packets that contain the schedule of the sensor.
If a sensor detects adjacent sensors with a predefined listen period it uses the same period, otherwise it chooses its own period advertising it to the neighbors.
Even after the initialization of the sensor it's possible to revert to something else's schedule, if its own schedule is not shared with anybody else.

Since a sensor can receive a packet only in its listen period, the sender may need to turn on its radio also outside its listen period, so it should know all the listen periods of its neighbors.
Before sending a packet the media is sensed, if busy it tries again in the slot, the collision avoidance mechanism used is based on RTS/CTS as in IEEE 802.11.

While travelling across a multihop path a packet may have to wait in the worst case for the listen period of each intermediate node, accumulating latency at each hop.
This situation should be mitigated by the fact that hopefully a certain number of sensors will converge towards the same schedule, even though there is not any guarantee of convergence.
In fact depending on the topology it may be impossible for a sensor to have a listen period compatible with all its neighbors.

### B-MAC
In B-MAC a node can send whenever it wants using packets that contain a very long preamble in the header.
The receiver activates its radio periodically to check if there is a preamble on the air, this activity is called preamble sampling and it is based on a low-power-listening mode.
Obviously the preamble should be longer than the sleep period, because of this B-MAC costs more in transmission but save energy in reception since the preamble sampling can be very short and cheap.

The energy consumption can be modeled as follows.
Assume that $f_c$ is the frequency of checking the medium for each sensor and that the medium is sensed for $t_c$ seconds, then the duty cycle in a second of time is:

$$
dc^{\textrm{check}} = f_c \cdot t_c
$$

Given a packet length in seconds of $t_d$ and a preamble length in seconds of $t_p$, the duty cycle for a transmitter is:

$$
dc^{\textrm{tx}} = f_d \cdot (t_p + t_d)
$$

Assuming $\epsilon$ to be the fraction of the preamble that has been captured by the receiver, its duty cycle is:

$$
dc^{\textrm{rx}} = f_d \cdot (t_p \cdot \epsilon + t_d)
$$

Now assuming that power in Watt required to transmit to be $p_{tx}$ and to receive $p_{rx}$ it is possible to compute the energy spent in Joule using for $t$ seconds.

$$
E = \sum_{s \in \{\textrm{check},\textrm{tx},\textrm{rx},\textrm{none}\} } p_s \cdot dc^s
$$
$$
E(t) = t \cdot E
$$

This simple and transparent protocol may turn to be expensive in the long run since the preamble sampling is not negligible.

### X-MAC
This protocol is an evolution of B-MAC aimed to reduce the impact of long preambles.
The transmitter fragments the preamble and inserts the ID of the receiver in each of this fragments.
The correct receiver of the packet is so able to interrupt the preamble to request the packet.

The protocol BoX-MAC is a further development of X-MAC that sends the actual packet instead of a preamble, so that the receiver only has to respond with an acknowledgement to stop the repetition of the message.

### Polling
Polling is an asymmetrical MAC technique that is combined with synchronization.

One master node issues periodic beacons, while several slaves can keep the radio off whenever they want.
If the master receives a message for a slave it stores the message and advertises it in the beacon, when the slave turns on the radio it waits for the beacon and recognizing that there is a pending message it requests it to the master.

## Network Protocols
Sensor networks are mostly data centric.
The identification of a node is less meaningful than its capabilities, nonetheless traditional routing protocols are not practical because of the large routing tables and the size of packet headers.
There are also two main issues in the network level: the implosion problem due to flooding based dissemination and the overlap problem due to sensors covering an overlapping geographical region.

It's important to use data centric routing protocols that are able to aggregate informations and are location aware to handle this characteristic scenario.

### Directed diffusion
Directed diffusion is a data-centric network protocol targeted to perform distributed sensing of environmental phenomena.
The sensor network is programmed to respond to location and movement-aware queries.
All of the data in the network is named data generated by sensors as attribute-value pairs.
The device that is in charge of querying the network is called sink, directed diffusion protocol works also in presence of multiple sinks.

To resolve a query the sink disseminates a sensing task in the network using messages called interests.
Interests are composed by a sequence of attribute-value pairs that describe the task, for example the type of data requested, the interval of events, the duration of the whole sensing request and the region of interested sensors.

The nodes receiving an interest may forward the interest to a subset of neighbors if they haven't already received the same request, this is checked by using a unique ID assigned to the interest.
If the node accepts an interest it must set up a gradient that contains a copy of the interest and the sensor from which the interest originally came.
The interests are kept in an internal cache where they expire according to a timer.

When a sensor detects an event matching with an interest in cache starts sampling the event at the largest sampling rate of the corresponding gradients.
The sensor sends sampled data to the neighbors interested, by eventually lowering the rate.
The neighbors forward the data if and only if a corresponding interest, within a gradient, is still in the cache.
This behaviour could lead to the implosion problem, since the same message could arrive at different ratios at the sink.

Since each sensor is associated with a unique ID, it's possible for the sink to reinforce the paths to a subset of specific sensor to improve the quality of received that.
To improve the quality of received data the reinforcement of an interest are required with higher sampling rate, this also is useful to contrast the implosion problem.
Reinforcement is usually done after a first broadcast dissemination, so once the sink already started receiving data matching the exploratory interest.

![State machine of a sensor in directed diffusion\label{fig:dd_machine}](assets/dd_machine.png)

The protocol can be easily represented using a two-state machine as in figure \ref{fig:dd_machine}, and it's suitable for implementation on low-end devices.
It's a scalable and robust protocol that results to be effective in applications that do not require complex data aggregation/preprocessing.
The implicit assumption of directed diffusion is that the overall system can survive to lost messages, considering the they will flow constantly, and to redundant messages.

The tree structure constructed by the sink is scalable but it's not completely fair for what concerns power consumption.
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

