# Managing mobility in cellular networks
A cellular network is composed by a set of a cells, each one one covering a distinct geographical region and connected by a Mobile Switching Center (MSC) that also manages the call setup and handles mobility.
A cell is composed by a base station (BS), that has analogous functions to an access point of 802.11, and its mobile users.

The radio spectrum used for the mobile-to-BS communication can be handled in two different ways:

- Combined FDMA/TDMA, where the spectrum is divided in frequency channels, and each channel into time slots.
- CDMA, Code Division Multiple Access.

A Base Station System (BSS) is composed by multiple base stations grouped by a Base Station Controller.
It should be noticed that up to 3G the data communication was parallel in respect to the voice one, that still used old circuit switching techniques.

## Mobility
Actually mobility can be thought as a gradient concept, from the absence of mobility to its total presence, with all the possible shades in between.

The mobility could be handled by the routing mechanism, letting the routers advertise permanent address of mobile-nodes-in-residence via usual routing table exchange, but this cannot scale to millions of device like it's required nowadays.

The alternative is to let the end-systems handle the mobility.
Each mobile device must have a permanent address in an home network that can always be used to reach the mobile.
The home network is controlled by an home agent, that is a device that will perform mobility functions on behalf of mobile, when the mobile device is outside the home network.
The mobile device should be hosted by a visited network managed by a foreign agent that performs mobility on behalf of the mobile device, providing it a care-of-address.

The first step is the registration of a mobile-device in a visited network: the mobile contacts the foreign agent and receives the care-of-address, after the home agent has been notified that its mobile is resident in the visited network.

After the registration the communication can be routed in two ways:

- Indirect routing, the correspondent communicates to the home network that forwards to the visited network that replies directly to the correspondent.
It should be noticed that the foreign agent functions may be done by the mobile itself.
Also the mobile user can maintain on going connections by simply notifying the home network of the new position by the next foreign agent.
- In direct routing the correspondent gets the address of the visited network from the home agent and the it directly communicates with the mobile device from the visited network. In this way the communication is not transparent, also if the mobile device changes visited network again chaining in a direct-routing fashion is used.

## GSM
In the context of actual cellular networks, the home network is the network of cellular provider the user is subscribed to (TIM, Vodafone, etc.) that maintains a database called home location register (HLR).
A similar database is kept by the visited network, called visitor location register (VLR).

In GSM indirect routing is used, so the correspondent packets pass trough the home network and the visited network, consulting respectively the HLR and the VLR.

Inside the same network, so under the same Mobile Switching Center the mobile could change Base Station System using a procedure called handoff initialized by the old BSS for various reasons like signal power and load balance.
Anyway the GSM standard only defines how to perform handoff and not why it should be performed.
The handoff protocol is the following:

- Old BSS inform MSC of impending handoff, providing the list of multiple BSS
- MSC choses one BSS and notify it
- New BSS allocates radio channel for the upcoming mobile device
- New BSS notifies, through the MSC, that it's ready
- Old BSS notify the mobile device to perform handoff to the new BSS
- Mobile device contact the new BSS to activate the new channel
- Mobile notifies the MSC trough the new BSS that the handoff is complete
- Old BSS releases the resources after the MSC notifies it of the outcome of the overall operation

Handoff could also be performed between different MSCs, in that case chaining mechanism is used between all the traversed MSC.

