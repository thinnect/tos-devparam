/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
generic module DataLengthParameterP() {
	provides {
		interface DeviceParameter;
	}
}
implementation {

	PROGMEM const char m_parameter_id[] = "tosh_data_length";

	task void data_length() {
		char id[sizeof(m_parameter_id)];
		uint8_t tdl = TOSH_DATA_LENGTH;
		strcpy_P(id, m_parameter_id);
		signal DeviceParameter.value(id, DP_TYPE_UINT8, &tdl, sizeof(tdl));
	}

	command error_t DeviceParameter.set(void* value, uint8_t length) { return FAIL; }

	command error_t DeviceParameter.get() { return post data_length(); }

	command bool DeviceParameter.matches(const char* identifier) { return 0 == strcmp_P(identifier, m_parameter_id); }

}
