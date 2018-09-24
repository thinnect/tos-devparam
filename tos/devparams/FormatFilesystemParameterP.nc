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

	command char GetSet.get() {
		return m_value;
	}

	error_t setValue(char value) {
		if(m_value != value) {
			char id[16+1];
			strcpy_P(id, m_parameter_id);
			if(call NvParameter.store(id, &value, sizeof(value) == SUCCESS)) {
				m_value = value;
				return SUCCESS;
			}
			return ERETRY;
		}
		return EALREADY;
	}

	command void Set.set(char value) {
		setValue(value);
	}

	command void GetSet.set(char value) {
		setValue(value);
	}

	task void responseTask() {
		char id[sizeof(m_parameter_id)];
		strcpy_P(id, m_parameter_id);
		signal DeviceParameter.value(id, DP_TYPE_STRING, &m_value, sizeof(char));
	}

	command error_t DeviceParameter.set(void* value, uint8_t length) {
		if(length == sizeof(m_value)) {
			error_t err = setValue(*((char*)value));
			if((err == SUCCESS)||(err == EALREADY)) {
				post responseTask();
				return SUCCESS;
			}
			return err;
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
