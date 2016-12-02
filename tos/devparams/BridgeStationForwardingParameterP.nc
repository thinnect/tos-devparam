/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
generic module BridgeStationForwardingParameterP() {
	provides {
		interface DeviceParameter;
	}
	uses {
		interface Set<am_addr_t> as SetForwardAddress;
		interface Get<am_addr_t> as GetForwardAddress;
	}
}
implementation {

	PROGMEM const char m_parameter_id[] = "forward_address";

	// nx_am_addr forward_address ... 0xFFFF - everything, 0x000 - nothing or specific address(and broadcast)

	task void notify() {
		char id[sizeof(m_parameter_id)];
		nx_am_addr_t addr;
		addr = call GetForwardAddress.get();
		strcpy_P(id, m_parameter_id);
		signal DeviceParameter.value(id, DP_TYPE_RAW, &addr, sizeof(addr));
	}

	command error_t DeviceParameter.set(void* value, uint8_t length) {
		if(length == sizeof(nx_am_addr_t)) {
			call SetForwardAddress.set(*((nx_am_addr_t*)value));
			post notify();
			return SUCCESS;
		}
		return EINVAL;
	}

	command error_t DeviceParameter.get() { return post notify(); }

	command bool DeviceParameter.matches(const char* identifier) { return 0 == strcmp_P(identifier, m_parameter_id); }

}
