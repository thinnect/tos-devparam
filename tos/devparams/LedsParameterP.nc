/**
 * Control device LEDs.
 *
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
generic module LedsParameterP() {
	provides {
		interface DeviceParameter;
	}
	uses {
		interface Leds;
	}
}
implementation {

	PROGMEM const char m_parameter_id[] = "leds";

	task void ledsTask() {
		char id[sizeof(m_parameter_id)];
		nx_uint8_t leds;
		leds = call Leds.get();
		strcpy_P(id, m_parameter_id);
		signal DeviceParameter.value(id, DP_TYPE_UINT8, &leds, sizeof(leds));
	}

	command error_t DeviceParameter.set(void* value, uint8_t length) {
		if(length == sizeof(nx_uint8_t)) {
			uint8_t leds = (uint8_t)(*((nx_uint8_t*)value));
			call Leds.set(leds);
			post ledsTask();
			return SUCCESS;
		}
		return EINVAL;
	}

	command error_t DeviceParameter.get() { return post ledsTask(); }

	command bool DeviceParameter.matches(const char* identifier) { return 0 == strcmp_P(identifier, m_parameter_id); }

}
