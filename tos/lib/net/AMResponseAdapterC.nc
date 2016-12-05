/**
 * Adapter for wiring components that use Send/Receive without addresses to
 * ActiveMessage Send/Receive with the assumption that the protocol is always
 * Request-Response - first a message comes from Receive and then a response is
 * sent back with Send. Also assumes that only a single node tries to communicate
 * within the window it takes to compose a response. Basically it just remembers
 * the source address and sends the response to that address.
 *
 * @author Raido Pahtma
 * @license MIT
 */
generic module AMResponseAdapterC() {
	provides {
		interface Send;
		interface Receive;
	}
	uses {
		interface AMPacket;
		interface AMSend;
		interface Receive as AMReceive;
	}
}
implementation {

	am_addr_t m_address = 0;

	event message_t* AMReceive.receive(message_t* message, void* payload, uint8_t len) {
		m_address = call AMPacket.source(message);
		return signal Receive.receive(message, payload, len);
	}

	command error_t Send.send(message_t* msg, uint8_t len) {
		if((0 < m_address)&&(m_address < AM_BROADCAST_ADDR)) {
			return call AMSend.send(m_address, msg, len);
		}
		return EINVAL;
	}

	command error_t Send.cancel(message_t* msg) {
		return call AMSend.cancel(msg);
	}

	command void* Send.getPayload(message_t* msg, uint8_t len) {
		return call AMSend.getPayload(msg, len);
	}

	command uint8_t Send.maxPayloadLength() {
		return call AMSend.maxPayloadLength();
	}

	event void AMSend.sendDone(message_t* msg, error_t error) {
		signal Send.sendDone(msg, error);
	}

}
