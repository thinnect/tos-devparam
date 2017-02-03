/**
 * User assigned "appliance" identificator.
 *
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
generic module DeviceApplianceParameterP() {
	provides {
		// TODO expose the value with some kind of interface
		interface DeviceParameter;
	}
	uses {
		interface NvParameter;
	}
}
implementation {

	PROGMEM const char m_appliance_id[] = "appliance";

	char m_appliance[32+1] = "";

	task void responseTask() {
		char id[16+1];
		strlcpy_P(id, m_appliance_id, sizeof(id));
		signal DeviceParameter.value(id, DP_TYPE_STRING, &m_appliance, strnlen(m_appliance, sizeof(m_appliance)-1));
	}

	command error_t DeviceParameter.set(void* value, uint8_t length) {
		if(length <= sizeof(m_appliance)-1) {
			char v[sizeof(m_appliance)];
			memcpy(v, value, length);
			memset(v+length, 0, sizeof(v)-length);
			if(strcmp(m_appliance, v) != 0) {
				char id[16+1];
				strcpy_P(id, m_appliance_id);
				if(call NvParameter.store(id, &v, sizeof(m_appliance)-1) == SUCCESS) {
					memcpy(m_appliance, v, sizeof(m_appliance));
					post responseTask();
					return SUCCESS;
				}
				return ERETRY;
			}
			post responseTask();
			return SUCCESS;
		}
		return EINVAL;
	}

	command error_t DeviceParameter.get() {
		return post responseTask();
	}

	bool matches(const char* identifier) {
		return 0 == strcmp_P(identifier, m_appliance_id);
	}

	command bool DeviceParameter.matches(const char* identifier) {
		return matches(identifier);
	}

	event bool NvParameter.matches(const char* identifier) {
		return matches(identifier);
	}

	event error_t NvParameter.init(void* value, uint8_t length) {
		if(length <= sizeof(m_appliance)-1) {
			memcpy(m_appliance, value, length);
			memset(m_appliance+length, 0, sizeof(m_appliance)-length);
			return SUCCESS;
		}
		return ESIZE;
	}

}
