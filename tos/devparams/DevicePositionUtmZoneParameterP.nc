/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
generic module DevicePositionUtmZoneParameterP() {
	provides {
		interface Get<uint8_t>;
		interface Set<uint8_t>;
		interface Set<uint8_t> as Save;
		interface DeviceParameter;
	}
	uses {
		interface NvParameter;
	}
}
implementation {

	PROGMEM const char m_zone_id[] = "utm_zone";

	uint8_t m_zone = 0;

	command uint8_t Get.get() {
		return m_zone;
	}

	command void Set.set(uint8_t value) {
		m_zone = value;
	}

	command void Save.set(uint8_t value) {
		call DeviceParameter.set(&value, sizeof(uint8_t));
	}

	task void responseTask() {
		char id[16+1];
		strcpy_P(id, m_zone_id);
		signal DeviceParameter.value(id, DP_TYPE_UINT8, &m_zone, sizeof(uint8_t));
	}

	command error_t DeviceParameter.set(void* value, uint8_t length) {
		if(length == sizeof(uint8_t)) {
			uint8_t v = *((uint8_t*)value);
			if(v != m_zone) {
				char id[16+1];
				strcpy_P(id, m_zone_id);
				if(call NvParameter.store(id, &v, sizeof(v)) == SUCCESS) {
					m_zone = v;
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
		return 0 == strcmp_P(identifier, m_zone_id);
	}

	command bool DeviceParameter.matches(const char* identifier) {
		return matches(identifier);
	}

	event bool NvParameter.matches(const char* identifier) {
		return matches(identifier);
	}

	event error_t NvParameter.init(void* value, uint8_t length) {
		if(length == sizeof(uint8_t)) {
			m_zone = *((uint8_t*)value);
			return SUCCESS;
		}
		return ESIZE;
	}

}
