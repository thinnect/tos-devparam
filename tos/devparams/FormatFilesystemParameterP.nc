/**
 * Force filesystem format parameter.
 *
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
generic module FormatFilesystemParameterP() {
	provides {
		interface Get<char>;
		interface Set<char>;
		interface GetSet<char>;
		interface DeviceParameter;
	}
	uses {
		interface NvParameter;
	}
}
implementation {

	PROGMEM const char m_parameter_id[] = "format_fs";

	char m_value = 'n';

	command char Get.get() {
		return m_value;
	}

	command void Set.set(char value) {
		m_value = value;
	}

	command char GetSet.get() {
		return m_value;
	}

	command void GetSet.set(char value) {
		m_value = value;
	}

	task void responseTask() {
		char id[sizeof(m_parameter_id)];
		strcpy_P(id, m_parameter_id);
		signal DeviceParameter.value(id, DP_TYPE_STRING, &m_value, sizeof(char));
	}

	command error_t DeviceParameter.set(void* value, uint8_t length) {
		if(length == sizeof(m_value)) {
			char v = *((char*)value);
			if(v != 0) {
				char id[16+1];
				strcpy_P(id, m_parameter_id);
				if(call NvParameter.store(id, &v, sizeof(v) == SUCCESS)) {
					m_value = v;
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
		return 0 == strcmp_P(identifier, m_parameter_id);
	}

	command bool DeviceParameter.matches(const char* identifier) {
		return matches(identifier);
	}

	event bool NvParameter.matches(const char* identifier) {
		return matches(identifier);
	}

	event error_t NvParameter.init(void* value, uint8_t length) {
		if(length == sizeof(m_value)) {
			m_value = *((char*)value);
			return SUCCESS;
		}
		return ESIZE;
	}

}
