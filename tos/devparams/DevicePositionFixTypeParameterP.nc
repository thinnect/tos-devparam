/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
generic module DevicePositionFixTypeParameterP() {
	provides {
		interface Get<char>;
		interface Set<char>;
		interface Set<char> as Save;
		interface DeviceParameter;
	}
	uses {
		interface NvParameter;
	}
}
implementation {

	PROGMEM const char m_fix_id[] = "geo_fix_type";

	char m_fix = 'U'; // U - unknown, F - fixed, G - GNSS, A - area, L - local positioning

	command char Get.get() {
		return m_fix;
	}

	command void Set.set(char value) {
		m_fix = value;
	}

	command void Save.set(char value) {
		call DeviceParameter.set(&value, sizeof(char));
	}

	task void responseTask() {
		char id[16+1];
		strcpy_P(id, m_fix_id);
		signal DeviceParameter.value(id, DP_TYPE_STRING, &m_fix, sizeof(char));
	}

	command error_t DeviceParameter.set(void* value, uint8_t length) {
		if(length == sizeof(char)) {
			char v = *((char*)value);
			if(v != m_fix) {
				char id[16+1];
				strcpy_P(id, m_fix_id);
				if(call NvParameter.store(id, &v, sizeof(v)) == SUCCESS) {
					m_fix = v;
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
		return 0 == strcmp_P(identifier, m_fix_id);
	}

	command bool DeviceParameter.matches(const char* identifier) {
		return matches(identifier);
	}

	event bool NvParameter.matches(const char* identifier) {
		return matches(identifier);
	}

	event error_t NvParameter.init(void* value, uint8_t length) {
		if(length == sizeof(char)) {
			m_fix = *((char*)value);
			return SUCCESS;
		}
		return ESIZE;
	}

}
