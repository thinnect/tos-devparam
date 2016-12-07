/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
generic module DevicePositionUtmBandParameterP() {
	provides {
		interface Get<char>;
		interface DeviceParameter;
	}
	uses {
		interface NvParameter;
	}
}
implementation {

	PROGMEM const char m_band_id[] = "utm_band";

	char m_band = 'U';

	command char Get.get() {
		return m_band;
	}

	task void responseTask() {
		char id[16+1];
		strcpy_P(id, m_band_id);
		signal DeviceParameter.value(id, DP_TYPE_STRING, &m_band, sizeof(char));
	}

	command error_t DeviceParameter.set(void* value, uint8_t length) {
		if(length == sizeof(char)) {
			char v = *((char*)value);
			if(v != m_band) {
				char id[16+1];
				strcpy_P(id, m_band_id);
				if(call NvParameter.store(id, &v, sizeof(v)) == SUCCESS) {
					m_band = v;
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
		return 0 == strcmp_P(identifier, m_band_id);
	}

	command bool DeviceParameter.matches(const char* identifier) {
		return matches(identifier);
	}

	event bool NvParameter.matches(const char* identifier) {
		return matches(identifier);
	}

	event error_t NvParameter.init(void* value, uint8_t length) {
		if(length == sizeof(char)) {
			m_band = *((char*)value);
			return SUCCESS;
		}
		return ESIZE;
	}

}
