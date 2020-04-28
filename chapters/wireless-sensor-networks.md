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
This protocol tries to overcome the limitations of directed diffusion and of other similar protocols, by providing arbitrary node-to-node routing and assuming limited resources and small communication overhead.
The protocol is highly scalable since there is no use for route discovery and few control packets are used, without the need of large route caches.

The nodes in the network must be aware of their position and of the position of their neighbors in a two dimensional space, so that when sending a message the source knows only the geographical coordinates of the destination.

There are two different modes in which a package can traverse the network: greedy forwarding and perimeter forwarding.

#### Greedy forwarding
In greedy forwarding, considering a packet from a node $x$ to a destination $D$, the next hop is chosen as the node most closer to $D$.

$$
y = \arg\min_y d(y,D) < d(x,D)
$$

Greedy forwarding fails if the packets encounters a void, that means that the actual node $x$ is closer to the destination than all of its neighbors, but it can't reach $D$ anyway.

#### Perimeter forwarding
Perimeter forwarding is used when greedy forwarding fails, routing around the void using a rule (usually Right-Hand-Rule RHR) to define rotation order, exploring the edges of the polygon enclosing the void.
In practice suppose that the packet lands on node $y$ from node $x$, using RHR the next edge to follow is the first counterclockwise edge from $(x,y)$.

GPSR switches back to greedy forwarding whenever it finds a node that is closer than $x$ to the destination, where $x$ is the last node visited before switching to perimeter forwarding.

The graph of the WSN is a non-planar embedding of a graph, so edges may cross and the RHR may take a degenerate tour that does not trace the boundary of a closed polygon.
For this reason, GPSR applies the perimeter mode to a planar graph $P$ obtained from the Relative Neighborhood Graph and the Gabriel Graph of the original non-planar graph $G$.
If $G$ is connected then $P$ is connected, also $P$ is obtained from $G$ by removing edges and it is computed with a distributed algorithm executed along with the perimeter mode packet forwarding.

![To select $(u,v)$ in RNG, $w$ must be out of the red area. To select it in the GG, $w$ must be out of the blue area. \label{gpsr_planar}](assets/gpsr_planar.png)

#### Relative neighborhood graph
The relative neighborhood graph of $G$ is the set of all and only the edges that describe the minimal path for each pair of nodes.

$$
(u,v) \in P \iff (u,v) \in G \land
d(u,v) \leq \max_{\forall w \in N(u) \cup N(v)} d(u,w)+d(w,v)
$$

#### Gabriel graph
The Gabriel graph of $G$ is the set of all and only the edges that describe the minimal quadratic path for each pair of nodes.

$$
(u,v) \in P \iff (u,v) \in G \land
d(u,v)^2 \leq \max_{\forall w \in N(u) \cup N(v)} d(u,w)^2 + d(w,v)^2
$$

The Gabriel graph keeps more links than relative neighborhood graph, and actually RNG is a subgraph of GG, anyway both are suitable to use for perimeter mode in GPRS.
A visualization of the conditions for RNG and GG is in figure \ref{gpsr_planar}, the node $w$ to be searched is called "witness".

A planar graph has two types of faces: the interior faces from the closed polygonal regions bounded by the graph edges, and the exterior face from the outer boundary of the graph.

When in perimeter mode GPSR uses the right hand rule to reach an edge which crosses the line passing in $x$ and $D$ and is closer to $D$ than $x$.
Using that edge, the packet moves to the adjacent face crossed by the line, at this time the current edge $e_0$ and the point of intersection between the line and the edge $L_f$ are stored.

If $D$ is reachable from $x$ then GPSR guarantees to find a route, otherwise the packet will reach the internal face containing the coordinates of $D$ or the external face.
Not finding the node $D$ the packet will tours around the face until it passes again through edge $e_0$, at that point the packet is discharged.

GPSR relies on updated information about the position of the neighbors, so it needs a freshly planar version of the graph to avoid performance degradation.
Performing planarization at each topology change is not a good idea, since nodes may move within a node's transmission range, continuously changing the selection of links by GG or RNG.
A proactive approach is instead used: nodes periodically communicate their position to their neighbors.
These beacon packets are used to keep updated the list of neighbors and to force planarization when the changes are excessive.

Planarization could fail due to unidirectional links caused for example by obstacles or by non circular transmission ranges.
As already observed without planarization loops may arise.

![Cross links using mutal witness. $(a,d)$ uses $b$ as witness and $(b,c)$ uses $d$. \label{fig:crosslinks}](assets/crosslinks.png)

#### Mutual witness
The mutual witness protocol is an extension of the planarization algorithms.
When analyzing the edge $(u,v)$ the edge is removed only if the witness $w$ is visible to both of the nodes, so not only the distance is considered as in standard GG or RNG creation.
Anyway the procedure is not perfect, since as seen in figure \ref{fig:crosslinks} non planar graphs can result from the use of the mutual witness rule.

#### Cross Link Detection Protocol
CLDP operates on the full graph, so without preliminary planarization.
Each node probes each of its links to see if it is crossed (in a geographic sense) by one or more other links.
A probe initially contains the locations of the endpoints of the link being probed, and traverses the graph using the right-hand rule.
When a node receives a probe it controls the coordinates of all the nodes that the probe traversed, if it finds a link crossing the current link it records the information in the probe.
When the probe return to the source it may decide to remove one of the crossing links.

However a link removal may result in a network disconnection, for this reason the probe counts the number of times it crosses a link.
If a link had been crossed only once then it can be removed, since it means that there exist a loop and thus it is possible to reach any node in the loop by an alternative path.

Link removal may require additional communications between nodes.
Assume that node $w$ is testing its outgoing node $L$ that crosses link $L'$, to reduce the overhead CLDP uses some rules:

- If nor $L$ neither $L'$ can be removed then both links are kept
- If both links can be removed then $w$ removes $L$, since it requires less communication
- If $L'$ cannot be removed, $L$ is removed, and vice versa

## Data-Centric Storage
In a wireless sensor network there is an important tradeoff between the transmission and the storage of the informations.
There are three possible ways to store data from a WSN:

1. The sensed information is sent to the sink, that then stores it outside of the WSN.
2. The information is locally kept in the sensor, it's up to the sink to flood a query in the whole WSN to retrieve it.
3. Data centric storage, where different nodes in the WSN are responsible of storing different data types, then the sink can retrieve the whole data or a summary per type.

To compare this three techniques assume now that there are $T=Q$ different types of events or queries in the network, $D_{tot}$ is the number of events detected in a fixed amount of time and $D_q$ is the same for a fixed type of data.
Given $n$ nodes in the network the number of packets needed to transmit an information is $O(n)$ for flooding the WSN and $O(\sqrt n)$ for unicast.
Actually there are two metrics to consider, the total usage is the total number of packets in the WSN and hotspot usage that is the maximum number packets sent or received by a given node, for instance the sink.

| Type | Total | Hotspot |
|-|-|-|
| External storage | $D_{tot} * \sqrt n$ | $D_{tot}$ |
| Local storage | $Q \cdot n + Q \cdot D_q \cdot \sqrt n$ | $Q + Q \cdot D_q$ |
| DCS list | $D_{tot} \cdot \sqrt n + Q \cdot \sqrt n + Q \cdot D_q \cdot \sqrt n$ | $Q + Q \cdot D_q$ |
| DCS summary | $D_{tot} \cdot \sqrt n + 2 \cdot Q \cdot \sqrt n$ | $2 \cdot Q$ |

In data-centric storage the events are named keys and corresponding data are stored by names in the network, queries are directed to the node that stores events of that key.
There are so two operations supported by DCS: `Put(k,v)` and `Get(k)`.
Both of these operations depend on a geographic hash function $h(k)$ that is able to produce geographic coordinates $(x,y)$.

#### Perimeter refresh protocol
Mobility or failure of a sensor may result in unavailability of a stored value, to provide persistence and consistency a possible solution is the perimeter refresh protocol.
Assume from now on that the node $u$ has been selected as the home node for the key $k$, since it's the nearest node to $(x,y)$.

PRP ensures persistence by selecting a perimeter of $u$ computed by GPSR and replicating all the known values of the key $k$ in all the nodes of the perimeter.
Consistency is ensured since $u$ constantly generates refresh packets to destination $(x,y)$, if this packets reach a new destination $v$ then $v$ is elected as home node for the key $k$ and replicates the data in itself and its perimeter.
Also the replica nodes in the perimeter checks on the home node using refresh packets, all these behaviours are regulated by timers.

#### Structured replication
The DCS should easily scale to multiple keys without overloading the nodes, structured replication is a way to load balance between multiple nodes.
To each key $k$ are associated a root and $4d-1$ mirrors, then the node stores data in its closest mirror of $h(k)$.
The retrieval of a value involves querying the root and possibly all mirrors of its mirrors.

## Physical and virtual coordinates
Traditional routing protocols for ad-hoc networks are not practical because of large routing or path caches and the size of packet headers, the geographic routing appears so to be a good option.
The coordinates can be obtained by equipping nodes with GPS, but this solution comes with an additional cost and it's not always feasible.
When no GPS system is available there are different ways to approximate the physical coordinates of the nodes.

#### Identify boundaries
The first task is to identify the boundary nodes of the network:

- Choose at random two bootstrap nodes
- Let the bootstraps broadcast `HELLO` packets in the network
- Each node is able to determine its hop distance from the two bootstrap nodes, the nodes with maximum hop distance are classified as boundary nodes.

#### Position boundaries
Now that the boundary nodes are known it's possible to approximate their coordinates:

- Each boundary node broadcasts `HELLO` packets in the network
- Each boundary node is able to determine its hop distance with all of the other boundary nodes, this is called perimeter vector.
- Each boundary node broadcasts its perimeter vector to the entire network.

Assume now that $h(i,j)$ is the hop-distance between the two boundary nodes $i,j$ and $d(i,j)$ their euclidean distance, their positions can be found as the position that minimize the following optimization problem.
$$
\sum_{i,j \in p} ( h(i,j) - d(i,j))^2
$$

#### Position other nodes
All of the other nodes in the network can now approximate their position $(x_i,y_i)$ in the network by using their neighbors $N_i$ with the following iterative process:

$$
x_i = \sum_{k\in N_i} \frac{x_k}{|N_i|}, \quad y_i = \sum_{k\in N_i} \frac{y_k}{|N_i|}
$$

#### Routing with recursive virtual coordinate
An alternative is to use full virtual coordinates without trying to approximate physical coordinates, one of this is the RRVC protocol.
Given two anchors $A,B$ in a network any other node position is described as the hop-distance from the anchors, the anchors also partition the networks between the nodes nearer to $A$ and those nearer to $B$.
This partition can be iterated to improve the coordinates precision.

## Clustering in WSN
Clustering imposes a hierarchy to a WSN whose organization is otherwise flat.
In this hierarchy it's possible to identify cluster heads that are dynamically assigned by the clustering protocol.
The cluster heads set up and maintain the logical backbone of the network and coordinate the nodes to improve scalability and efficiency.

A hierarchy in the network simplifies several network protocols, in particular routing and route discovery.
For instance routing a packet from a node $u \to v$ is simpler using cluster heads $CH(\cdot)$.
First using intra-cluster communication the message is sent $u \to CH(u)$, then using inter-cluster from $CH(u)\to CH(v)$ and finally $CH(v) \to v$.

The clusters are constructed over the graph of logical links, in general to improve the communication logical links should overlap physical links as much as possible.
If a logical link does not have a physical link, it is implemented by a path of physical links as short as possible.

The clusters should also have a similar size, ideally the same size although this is often not possible.
The cluster heads have an overhead that depends on the size of the cluster, a similar size of clusters means a similar overhead across the network.

Given the dynamic nature of WSN and ad-hoc networks, stability is a desired feature for a clustering protocol.
Slight changes in the network topology should result in slight changes in the clustering or in no change at all.

#### $k$-neighbor clustering

![Example of $k$-neighbor clustering.\label{fig:knc}](assets/knc.png)

Using $k$-neighbor clustering the hop-distance between a node and its cluster head is limited as in:

$$
\forall u \in N \ldotp h(u,CH(u)) < k
$$

For instance with $k=1$ all the logical links within the cluster are also physical links, this is the case of Bluetooth and Zigbee.
Also for inter-cluster links a similar rule is applied to guarantee small paths of physical links.

$$
\forall u,v \in N \ldotp h(CH(u),CH(v)) < h, \quad h \geq k
$$

The nodes that provide connectivity between different clusters are called gateways.
An example of $k$-neighbor clustering with $k=1,h=2$ can be seen in figure \ref{fig:knc}.

#### Dominating set
A dominating set $D \subseteq N$ is the set of nodes such that

$$
\forall u \in N \setminus D \ldotp \exists v \in D \ldotp (u,v) \in E
$$

A dominant set is a feasible set of CH for a $1$-neighbor clustering of the network.

#### Connected dominating set
A connected dominating set $C \subseteq N$ for $G$ is a set of nodes such that $C$ is a dominating set and the subgraph $G' \subseteq G$ induced by $C$ is connected.
Selecting the set of cluster heads as the CDS of $G$ corresponds to cluster with $k=1,h=1$ and so to obtain a connected backbone.

#### Minimum connected dominating set
In general there exists several CDS for a graph, the MCDS problem consists in finding one of minimum cardinality, that is the smallest set of cluster heads for $k$-neighbor clustering with $k=1,h=1$.
This problem in NP-hard.

The cluster heads may keep their radios on to sustain the communication of the entire network, allowing other nodes to save energy.
The small size of the CDS is particularly desirable in this case: only a few nodes consume more energy, most of the nodes save energy.

#### Distributed and mobility adaptive clustering
DMAC is a simple clustering algorithm where each node in the network has a weight, which represents its willingness to become a cluster head.
Weights may depend on the combination of several parameters of a node, like its battery charge, its ID or its position.

Each node can be in three possible states: cluster head (CH), ordinary node (ON) or undecided (UN).
When DMAC starts each node broadcasts to its neighbors an `HELLO` message which contains the node ID, its weight and its status.
If a node has the maximum weight among its neighbors then it becomes a cluster head, all of its neighbors become ordinary nodes.
This procedure enforces $k=1$, hence the set of CH is a dominating set, and $2 \leq h \leq 3$.

When a node joins an already clustered network it should set its status to UN and sends an hello message to its neighbors that will consequently update their status.
Other than for topology changes the clusters should be updated for each weight change.

Chain reactions could arise when a node elects itself cluster head, and it's more likely as more nodes join the network.
This is in general undesirable since involved nodes have to reconfigure themselves and this induces additional overhead.
