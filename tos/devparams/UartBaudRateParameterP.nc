/**
 * Configurable UART baud rate parameter.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include "DeviceParameters.h"
generic module UartBaudRateParameterP(uint8_t uart_num) {
	provides {
		interface DeviceParameter;
	}
	uses {
		interface GetSet<uint32_t> as UartBaudRate;
		interface NvParameter;
	}
}
implementation {

	PROGMEM const char m_parameter_id[] = "uart%u_baudrate";

	task void responseTask() {
		char id[16+1];
		nx_uint32_t value;
		value = call UartBaudRate.get();
		snprintf_P(id, sizeof(id), m_parameter_id, uart_num);
		signal DeviceParameter.value(id, DP_TYPE_UINT32, &value, sizeof(value));
	}

	command error_t DeviceParameter.set(void* value, uint8_t length) {
		if(length == sizeof(uint32_t)) {
			int32_t v;
			v = *((nx_uint32_t*)value);

			if(v != call UartBaudRate.get()) {
				char id[16+1];
				snprintf_P(id, sizeof(id), m_parameter_id, uart_num);
				if(call NvParameter.store(id, &v, sizeof(v)) == SUCCESS) {
					call UartBaudRate.set(v);
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
		char id[16+1];
		snprintf_P(id, sizeof(id), m_parameter_id, uart_num);
		return 0 == strcmp(identifier, id);
	}

	command bool DeviceParameter.matches(const char* identifier) {
		return matches(identifier);
	}

	event bool NvParameter.matches(const char* identifier) {
		return matches(identifier);
	}

	event error_t NvParameter.init(void* value, uint8_t length) {
		if(length == sizeof(uint32_t)) {
			call UartBaudRate.set(*((uint32_t*)value));
			return SUCCESS;
		}
		return ESIZE;
	}

}
