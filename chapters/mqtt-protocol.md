# MQTT
The Massage Queuing Telemetry Transport (MQTT) is a communication protocol, lightweight and reliable. It's based on the publish/subscribe paradigm. It is lightweight because it needs a small code footprint, low network bandwidth, and lower packet overhead that guarantees better performance than HTTP. The main actors: the publisher, subscriber and the event service (knowns as broker). The first two, are clients and don't know each other meanwhile the broker knows both. The publisher and subscriber are fully decoupled in time, space and synchronization. Decoupling is guaranteed by the presence of the broker that acting as an intermediary, it receives all incoming messages from the publishers, filters them and distributes all messages to the subscribers and also manages the requests of subscription/unsubscription.

![MQTT event handling example](/assets/MQTTpub_sub.png=100x80 

Compared to the client-server architecture it allows greater scalability, by parallelizing the broker it is possible to connect millions of devices. 

The publisher and the subscriber need to know broker hostname/IP and port to publish/subscribe messages. 
Messages can be filtered on a certain subject or topic, the content of the message (for example a specific query) or the type of data. Publishers and subscribers need to agree on the topics beforehand.  Also, MQTT provides QoS to ensure reliability in the delivery of messages, there are three levels of QoS.  
Communication between the actors provides different kinds of messages:

![MQTT client/broker comunication](/assets/MQTT_protocol_example.png)

The CONNECT message, sent by clients to the broker, contains: 
- ClientID: a string that uniquely identifies the client at the broker. It can be empty: the broker assigns a clientID and it does not keep a status for the client (the parameter Clean Session must be TRUE)
- Clean Session (optional):  a boolean value that determines if the client requests a persistent session: if it's FALSE the broker will store all subscriptions and missed messages, otherwise the broker cleans all information of the client of the previous session.
- Username/Password (Optional)
- Will flags (optional): If and when the client disconnects unexpectedly, the broker will notify the other clients of the disconnection.
- KeepAlive (optional): The client commits itself to send a control packet (or a ping message) to the broker within a keep-alive interval.

The CONNECTACK message, response for the CONNECT message:
- Connect Acknowledgement flags: confirms whether the connection was successful or not.
- Session Present: indicates whether the broker has already a persistent session of the client

After connection, a client can publish messages. Each message contains a topic and a payload that contains the data.

The PUBLISH message: 
- PacketId: an integer, it's 0 if the QoS level is 0.
- TopicName: a string possibly structured in a hierarchy with «/» as delimiters, for example: «home/bedroom/temperature».
- QoS: 0, 1 or 2.
- RetainFlag: tells if the message is to be stored by the broker as the last known value for the topic. If a subscriber collects later, it will get this message.
- Payload: the actual message in any form.
- DupFlag: indicates that the message is a duplicate of a previous, un-acked message. Meaningful only if the QoS level is > 0.

SUBSCRIBE message:
- PacketId: an integer
- Topic1: a string (see publish messages)
- QoS1: 0, 1 or 2

The last 2 fields are repeated in a list for all the topics the sender wants to subscribe to.

SUBACK message:
- PacketId: the same integer of SUBSCRIBE message
- ReturnCode: one for each topic subscribed

Topics are strings that are organized in a hierarchy (topic levels) each level is separated by a «/», for example: home/firstfloor/bedroom/presence. Using wildcard extends the flexibility of this system:
- '+' is used to subscribe to an entire set of elements for a specific level of the hierarchy 
- '#' is used to subscribe to all publisher under a level of the hierarchy
Topics that begin with a «$» are reserved for internal statistics of MQTT and they cannot be published by clients.

### QoS
As said above in the MQTT protocol is provides a QoS system which is an agreement between publisher, broker and subscriber. There are three levels of QoS:

- QoS 0 (At most one): at this level the delivery uses the "best-effort" method, there aren't ACK messages and the broker doesn't store messages for offline clients. 

- QoS 1 (At least one): messages are numbered and stored by the broker until they are delivered to all subscribers. "At least one" means that each message is delivered at least once to the subscribers. There are ACK messages.

- QoS 2 (Exactly one): it’s the highest QoS level in MQTT and the slowest. It guarantees that each message is received exactly once by the subscriber and uses a double two-way handshake.

### Downgrade of QoS
As we already mentioned, the QoS definition and levels between the client that sends (publishes) the message and the client that receives the message are two different things. The QoS levels of these two interactions can also be different. The client that sends the PUBLISH message to the broker defines the QoS of the message. However, when the broker delivers the message to recipients (subscribers), the broker uses the QoS that the receiver (subscriber) defined during the subscription. For example, client A is the sender of the message. Client B is the receiver of the message. If client B subscribes to the broker with QoS 1 and client A sends the message to the broker with QoS 2, the broker delivers the message to client B (receiver/subscriber) with QoS 1. The message can be delivered more than once to client B, because QoS 1 guarantees delivery of the message at least one time and does not prevent multiple deliveries of the same message.

### Packet identifiers are unique per client
The packet identifier that MQTT uses for QoS 1 and QoS 2 is unique between a specific client and a broker within an interaction. This identifier is not unique between all clients. Once the flow is complete, the packet identifier is available for reuse. This reuse is the reason why the packet identifier does not need to exceed  65535. It is unrealistic that a client can send more than this number of messages without completing an interaction.

### Persistent session
If QoS is 1 or 2 the broker keeps persistent information about the state of the communication with clients. This information includes: the topics of the client, all messages that were not confirmed and those that were arrived when the client was offline. To achieve a persistent session at connection time the flag "cleanSession" must be set on FALSE. A particular type of persistent message is the retained messages which are normal messages with flag "retainedFlag" set on TRUE, their peculiarity consists that only the last sent message published on a certain topic will be stored. Retained messages make sense for unfrequent updates of a topic, for instance, the device status update (ON/OFF). 

### Last will & testament
Last Will & Testament is a type of message sent by the broker to notify other clients about the ungraceful disconnection of a client, for instance I/O error, KeepAlive message missing or a simple network disconnection. Like all the other messages last will is a normal message with topic, retained flag, QoS and a payload. To activate it is necessary to specify it at CONNECT time requiring a specific behavior about its last will.

## Alternatives to MQTT
In some cases the need for a centralized broker can be limiting in distributed IoT applications with diffused point-to-point communications, for instance, its overhead may easily become not compatible with end-devices capabilities as the network scales up or the fact that the broker is a single point of failure and it is essential to keep the network alive. Moreover, MQTT relies on TCP, which is not particularly cheap for lowend devices that, require much more resources than UDP for example, it uses connections that need to be established and maintained and it impacts on the batteries (and thus on the lifetime of the devices). An alternative to MQTT is Constrained Application Protocol (CoAP), which is a specialized web transfer protocol, useful in a constrained network for IoT, designed for machine-to-machine (M2M) applications such as smart energy and building automation. It's based on the Client/Server paradigm, uses the REST model, works similarly to HTTP but is based on UDP and provides a more light header suitable for devices that has small amounts of ROM and RAM. 
