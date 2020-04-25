# Cellular networks
A cellular network is composed by a set of a cells, each one one covering a distinct geographical region and connected by a Mobile Switching Center (MSC) that also manages the call setup and handles mobility.
A cell is composed by a base station (BS), that has analogous functions to an access point of 802.11, and its mobile users.

The radio spectrum used for the mobile-to-BS communication can be handled in two different ways:

- Combined FDMA/TDMA, where the spectrum is divided in frequency channels, and each channel into time slots.
- CDMA, Code Division Multiple Access.

A Base Station System (BSS) is composed by multiple base stations grouped by a Base Station Controller.
It should be noticed that up to 3G the data communication was parallel in respect to the voice one, that still used old circuit switching techniques.

## Mobility
Each host in a network holds a permanent address in its home network, this address can always be used to reach the host.
The home agent is the entity that will perform mobility functions on behalf of the host when the host is not in the home network but in another visited network.
In a visited network a care-of-address is assigned to the host, and a foreign agent also have to cooperate with the home agent to perform mobility functions.

The mobility could be handled by the routing mechanism, letting the routers advertise permanent address of mobile-nodes-in-residence via usual routing table exchange, but this cannot scale to millions of mobile devices like it's required nowadays.

The alternative is to let the end-systems handle the mobility.
The first step is the registration of a mobile-device in a visited network: the mobile contacts the foreign agent and receives the care-of-address, after that the home agent is notified that its mobile device is resident in the visited network.

After the registration the communication can be routed in two ways: indirected or directed.

In indirect routing, a correspondent communicates to the home network that is responsible to forward the packets to the visited network, this replies directly to the correspondent.
It should be noticed that the foreign agent functions may be done by the mobile itself.
Also the mobile user can maintain on going connections by simply notifying the home network of the new position by the next foreign agent.
This technique is obviously inefficient if the correspondent and the host are in the same visited network, because of the necessary triangularization.

In direct routing the correspondent gets the address of the visited network from the home agent and then it communicates directly with the mobile device in the visited network.
In this way the communication is not transparent, also if the mobile device changes visited network chaining is used.
In chaining the first visited network is called the anchor, and all of the traffic must be forwarded to the anchor even when the mobile changes visited network.

## Global System for Mobile communications
In the context of GSM cellular networks, the home network is the network of the provider the host is subscribed to (TIM, Vodafone, etc.) that maintains a database called home location register (HLR).
A similar database is kept by the visited network containing all the actual connected devices, called visitor location register (VLR).

In GSM indirect routing is used, so the correspondent packets pass trough the home network and the visited network, consulting respectively the HLR and the VLR.

Inside the same network, so under the same Mobile Switching Center the mobile could change Base Station System using a procedure called handoff initialized by the old BSS.
There are various reasons to perform handoff, like signal power issues and load balance.
Anyway the GSM standard only defines how to perform handoff and not the reasons why it should be performed.

The handoff protocol is the following:

1. Old BSS inform MSC of impending handoff, providing a list of BSS
2. MSC choses one BSS and notifies it to the selected one
3. New BSS allocates radio channel for the upcoming mobile device
4. New BSS notifies, through the MSC, that it's ready
5. Old BSS notify the mobile device to perform handoff to the new BSS
6. Mobile device contact the new BSS to activate the new channel
7. Mobile notifies the MSC trough the new BSS that the handoff is complete
8. Old BSS releases the resources after the MSC notifies it of the outcome of the overall operation

Handoff could also be performed between different MSCs, in that case chaining mechanism is used between all the traversed MSC.
