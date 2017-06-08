/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
generic module LifetimeParameterP() {
	provides {
		interface DeviceParameter;
	}
	uses {
		interface Get<uint32_t> as Lifetime;
	}
}
implementation {

	PROGMEM const char m_parameter_id[] = "lifetime";

	task void lifetime() {
		char id[sizeof(m_parameter_id)];
		nx_uint32_t up;
		up = call Lifetime.get();
		strcpy_P(id, m_parameter_id);
		signal DeviceParameter.value(id, DP_TYPE_UINT32, &up, sizeof(up));
	}

	command error_t DeviceParameter.set(void* value, uint8_t length) { return FAIL; }

	command error_t DeviceParameter.get() { return post lifetime(); }

	command bool DeviceParameter.matches(const char* identifier) { return 0 == strcmp_P(identifier, m_parameter_id); }

}
