/**
 * Count filesystem failures. Up to 255. Reset when firmware is changed.
 *
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
generic module FilesystemFailureCountParameterP() {
	provides {
		interface Get<uint8_t>;
		interface Set<uint8_t>;
		interface GetSet<uint8_t>;
		interface IncrementDecrement<uint8_t>;
		interface DeviceParameter;
	}
	uses {
		interface NvParameter;
		interface Boot as FirmwareChanged;
	}
}
implementation {

	PROGMEM const char m_parameter_id[] = "fs_fails";

	uint8_t m_value = 0;

	command uint8_t Get.get() {
		return m_value;
	}

	command uint8_t GetSet.get() {
		return m_value;
	}

	command uint8_t IncrementDecrement.get() {
		return m_value;
	}

	error_t setValue(uint8_t value) {
		if(m_value != value) {
			char id[16+1];
			strcpy_P(id, m_parameter_id);
			if(call NvParameter.store(id, &value, sizeof(value)) == SUCCESS) {
				m_value = value;
				return SUCCESS;
			}
			return ERETRY;
		}
		return EALREADY;
	}

	command void Set.set(uint8_t value) {
		setValue(value);
	}

	command void GetSet.set(uint8_t value) {
		setValue(value);
	}

	command void IncrementDecrement.set(uint8_t value) {
		setValue(value);
	}

	command void IncrementDecrement.increment() {
		if(m_value < 255) {
			setValue(m_value+1);
		}
	}

	command void IncrementDecrement.decrement() {
		if(m_value > 0) {
			setValue(m_value-1);
		}
	}

	task void responseTask() {
		char id[sizeof(m_parameter_id)];
		strcpy_P(id, m_parameter_id);
		signal DeviceParameter.value(id, DP_TYPE_UINT8, &m_value, sizeof(m_value));
	}

	command error_t DeviceParameter.set(void* value, uint8_t length) {
		if(length == sizeof(m_value)) {
			error_t err = setValue(*((uint8_t*)value));
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
			m_value = *((uint8_t*)value);
			return SUCCESS;
		}
		return ESIZE;
	}

	event void FirmwareChanged.booted() {
		setValue(0); // Reset value after a firmware update
	}

}
