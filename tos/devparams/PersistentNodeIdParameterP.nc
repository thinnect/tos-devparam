/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
generic module PersistentNodeIdParameterP() {
	provides {
		interface DeviceParameter;
	}
	uses {
		interface Get<am_addr_t>;
		interface Set<am_addr_t>;
		interface Timer<TMilli>;
	}
}
implementation {

	PROGMEM const char m_parameter_id[] = "TOS_NODE_ID";

	task void addrtask() {
		char id[sizeof(m_parameter_id)];
		nx_am_addr_t addr;
		addr = (nx_am_addr_t)call Get.get();
		strcpy_P(id, m_parameter_id);
		signal DeviceParameter.value(id, DP_TYPE_RAW, &addr, sizeof(addr));
	}

	command error_t DeviceParameter.set(void* value, uint8_t length) {
		if(length == sizeof(nx_am_addr_t)) {
			am_addr_t addr = (am_addr_t)(*((nx_am_addr_t*)value));
			if(addr != call Get.get()) {
				call Set.set(addr);
				post addrtask();
				call Timer.startOneShot(100); // Reboot the node so the address change can take effect.
				return SUCCESS;
			}
			return EALREADY;
		}
		return EINVAL;
	}

	event void Timer.fired() {
		#warning "This reboot solution only works for AVR"
		wdt_enable(1);
		while(1);
	}

	command error_t DeviceParameter.get() { return post addrtask(); }

	command bool DeviceParameter.matches(const char* identifier) { return 0 == strcmp_P(identifier, m_parameter_id); }

}
