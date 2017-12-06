/**
 * Reboot node after specified number of seconds.
 *
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
generic module RebootParameterP() {
	provides {
		interface DeviceParameter;
	}
	uses {
		interface Timer<TMilli>;
	}
}
implementation {

	PROGMEM const char m_parameter_id[] = "reboot";

	task void rebootTimeTask() {
		char id[sizeof(m_parameter_id)];
		nx_uint32_t timeleft;
		if(call Timer.isRunning()) {
			timeleft = call Timer.gett0() + call Timer.getdt() - call Timer.getNow();
		}
		else {
			timeleft = UINT32_MAX;
		}
		strcpy_P(id, m_parameter_id);
		signal DeviceParameter.value(id, DP_TYPE_UINT32, &timeleft, sizeof(timeleft));
	}

	command error_t DeviceParameter.set(void* value, uint8_t length) {
		if(length == sizeof(nx_uint32_t)) {
			uint32_t timeout = (uint32_t)(*((nx_uint32_t*)value));
			if(timeout == UINT32_MAX) {
				call Timer.stop();
			}
			else {
				call Timer.startOneShot(timeout); // Start reboot countdown
			}
			post rebootTimeTask();
			return SUCCESS;
		}
		return EINVAL;
	}

	event void Timer.fired() {
		#warning "This reboot solution only works for SILABS"
		NVIC_SystemReset();
		// wdt_enable(1);
		// while(1);
	}

	command error_t DeviceParameter.get() { return post rebootTimeTask(); }

	command bool DeviceParameter.matches(const char* identifier) { return 0 == strcmp_P(identifier, m_parameter_id); }

}
