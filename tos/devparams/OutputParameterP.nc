/**
 * Generic output parameter module.
 *
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
generic module OutputParameterP() {
	provides {
		interface DeviceParameter;
	}
	uses {
		interface Get<int32_t>;
		interface Set<int32_t>;
	}
}
implementation {

	PROGMEM const char m_parameter_id[] = "output";

	task void responseTask() {
		char id[sizeof(m_parameter_id)];
		nx_int32_t value;
		value = call Get.get();
		strcpy_P(id, m_parameter_id);
		signal DeviceParameter.value(id, DP_TYPE_INT32, &value, sizeof(value));
	}

	command error_t DeviceParameter.set(void* value, uint8_t length) {
		if(length == sizeof(nx_int32_t)) {
			int32_t v = (int32_t)(*((nx_int32_t*)value));
			call Set.set(v);
			post responseTask();
			return SUCCESS;
		}
		return EINVAL;
	}

	command error_t DeviceParameter.get() { return post responseTask(); }

	command bool DeviceParameter.matches(const char* identifier) { return 0 == strcmp_P(identifier, m_parameter_id); }

	default command void Set.set(int32_t value) { }

}
