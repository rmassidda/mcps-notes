# Wireless Networks
A wireless network is a network of mobile hosts connected by wireless links.
Such networks can operate using an infrastructure with base stations or without any centralized coordinator as an ad-hoc network.

A base station is a device typically connected to a wired network and it's responsible as a relay between the wireless hosts in its area and an outer network.
Other than the different architectures, wireless networks could be classified by the number of hops needed to deliver a package.

Multiple issues are specifics of the wireless medium, for instance:

- Decreased signal strength, the radio signal attenuates quicker as it propagates respect to the wired attenuation.
- Interference from other sources, the standard wireless frequencies are shared by multiple wireless devices, and possibly by other tools (engines, microwave ovens, etc.)
- Multipath propagation, the radio signal reflects off objects or ground, arriving at destination at slightly different times.

Two possible metrics to validate the effect of these issues are the signal-to-noise ratio (SNR) and in the bit-error-rate (BER).
These problematic characteristic of the medium also produce multiple challenges for wireless communication:

- Limited knowledge, a terminal cannot hear from all the others in the network, producing the hidden/exposed terminal scenarios.
- Limited terminals, the battery life, the memory, the computational power and the transmission range of a device are limited.
- Mobility/Failure of terminals, that can move in the range of different base-stations or move away from each other.
- Privacy, undermined by the easiness eavesdropping of ongoing communication.

## CSMA/CD
In a wired network a single channel is available for all the stations.
If frames are sent simultaneously the resulting signal is garbled, generating a collision detectable by all the hosts.

Given these context many different protocols were developed, culminating in the widely adopted Carrier-sense multiple access with collision detection (CSMA/CD) protocol:

- When a station has a frame to send, it listens to the channel to check if it's busy, waiting until it becomes idle.
- If a collision occurs the station waits a random amount of time and repeats the procedure.
- If a station is communicating and detects a collision it aborts immediately. (CD)

The random amount of time is selected by the binary exponential backoff technique.
This method uses contention slots equal to the double of the time necessary for the farthest stations to communicate.
After the $i$ collision each station waits a number of contention slots comprised in the interval $[0, 2^i -1]$, up to a maximum of $i=16$ after which the failure is reported to upper levels.

In CSMA/CD the interferences are detected by the transmitter, while in the wireless networks what matters are interferences at the receiver.
Using CSMA/CD in wireless networks leads to two known problematic scenarios: the hidden terminal and the exposed terminal.

![Hidden terminal](assets/hidden_terminal.png)

In the hidden terminal problem there are three stations, `A`, `B` and `C`.
Suppose that `A` and `C` want simultaneously to send a packet to `B`, and that `A` is not in the range of `C` and vice versa.
Both the senders would sense the medium as free, while `B` will only receive noise due to the collision in its range.

![Exposed terminal](assets/exposed_terminal.png)

Suppose now that `A` and `C` are both in the range of `B` and that `B` is sending a packet to `A`.
In the exposed terminal scenario using CSMA/CD `C` must refrain to send any packet, while there could be a station `D` out of the range of `B` to which `C` could communicate without any problem.

## MACA protocol
The Multiple Accesses with Collision Avoidance (MACA) protocol offers a simple solution to overcome the technical limitations of CSMA/CD in wireless networks.
The basic idea concerns stimulating the receiver using a short frame (Ready-to-send, RTS) into transmitting a short frame in turn (Clear-to-send, CTS).
Once the CTS has been received from the sender it can start transmitting the data frame.

The other stations hearing the CTS should refrain from requesting the media during the transmission of the data frame, of which the length is known since it is contained both in the RTS and the CTS.
This is sufficient to solve both the hidden and the exposed terminal issues.

If a station receives multiple RTS detects the collision and doesn't respond with a CTS.
The sending stations noticing that no CTS has been received assume a collision at the receiver and so they start binary exponential backoff before retrying.

The MACAW protocol offers various improvements over MACA:

- An ACK frame is introduced to acknowledge a successful data frame.
- Carrier sensing is required to keep a station from transmitting RTS when a nearby station is also transmitting an RTS to the same destination.
- Exponential backoff is run for each separate pair source/destination and not for the single station.
- A mechanisms to exchange information among stations and recognize temporary congestion problems is introduced.

## IEEE 802.11
IEEE 802.11 is part of the IEEE 802 set of LAN protocols, and specifies the set of media access control and physical layer protocols for implementing wireless local area networks in various frequencies, including but not limited to 2.4 GHz, 5 GHz, and 60 GHz frequency bands.
Introduced in the late 90s, different versions have been released during the years, improving the physical layers but leaving the unchanged the use of CSMA/CA in the MAC sublayer.
 
In the 802.11 architecture a group of stations operates under a given coordination function, this function can be decentralized (Distributed Coordination Function, DCF) or controlled by a unique station (Point Coordination Function, PCF).
The presence of a base station, know as access point (AP), requires the other stations to communicate with each other by channeling all the traffic through the centralized AP.
The access point can provide connectivity with other APs and so other groups of stations via a fixed infrastructure.
In the absence of an AP, 802.11 supports ad-hoc networks which are as always under the control of a single coordination function, but without the aid of an infrastructure network.

The DCF must be implemented by all stations, and DCF and PCF can be active at the same time in the same cell.

### Distributed Coordination Function
In the DCF the carrier sensing is performed both at the physical and the virtual level, and the channel is marked busy if either one of this two indicators is considered to be active:

Physical carrier sensing detects the presence of other active nodes by analyzing all the detected packets and detecting any activity in the channel due to other sources.
Virtual carrier sensing is performed by sending duration information in the header of an RTS, CTS or data frame and keeping the channel virtually busy up to the end of the data frame transmission.

The access to the medium is controlled through the use of growing inter-frame spaces (IFS): Short IFS, Point IFS and Distributed IFS.

This is the essence of the DCF based communication:

- The source senses the channel until it becomes idle, then waits DIFS and checks if the channel is still idle.
- The source sends the data, all the stations detecting the frame set a Network Allocation Vector (NAV) to mark the channel virtually busy for the time required for the data to be transmitted and the ACK to be received.
- The destination waits SIFS after receiving the data and then it sends the ACK.

A collision could happen because of multiple stations sending a data frame in the same instant, in that case the whole frame is sent before using binary exponential backoff to resend.
The contention time depends on the physical layer, anyway the backoff can be interrupted if the channel is sensed as busy and then the timer reprises after DIFS when it becomes idle again.

To avoid this situation, the RTS/CTS mechanism already seen in MACA can be implemented for all the possible frames or only for the enough big ones, in this case the other stations set multiple shrinking NAVs for the RTS, CTS and the data frame.

Also fragmentation can be useful to improve reliability, the frames are sent in sequence but each one waits for the acknowledgement of the previous.
In the case a fragments isn't correctly delivered the transmission reprises from that last one and not from the start, even in this case the NAV is specialized for the different fragments length other than for the RTS/CTS.
It should be noticed that if present, the RTS/CTS mechanism is used only for the first fragment.

### Point Coordination Function
In this operative mode the communication is under the control of the point coordinator (PC) that performs polling and enables stations to transmit without contending for the channel.
As previously stated this method must coexist with DCF.

According to a repetition interval, `CFP_RATE`, the PC periodically waits PIFS and sends a beacon frame to notify the start of a portion of time allocated for contention-free traffic.
The contention-free portion has a maximum time duration `CFP_MAX_DURATION` shared between all the stations, but the actual length is determined inside the beacon frame by the PC.
The contention-free period is always closed by a Contention Free End (CFE) frame.

Inside the contention-free period the communication are always initialized by the PC station, that can send data and/or a poll frame to a station, this can be done multiple times inside the same contention-free window.
After having received a beacon frame each station sets a NAV for the duration of the contention-free period, in that period they can only respond to data received using SIFS+ACK, or send data to any other station if polled by the PC.

With this model PC can also send to a non-PCF aware station that only has DCF, since this station will respond with an ACK, also messages can be fragmented as in DCF.

### Frame format specification
A frame of the 802.11 protocol most contain other important informations other than the obvious source and destination addresses and the data buffer.

The version of the protocol is needed, since given the interoperability at the MAC layer different protocols can coexist in the same cell.
There are three types of frames: management (association/dissociation, synchronization, authentication), control (handshaking, acknowledgement) and data (data transmission, possibly combined with polling and ACK in PCF).
Also the subtype of the frame may be specified to identify special frames like RTS, CTS and ACK.

Further informations regard the fragmentation, the encryption, the estimated time to complete the transmission and the CRC for error detection.
