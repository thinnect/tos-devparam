/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
generic module RadioChannelParameterP() {
	provides {
		interface DeviceParameter;
	}
	uses {
		interface RadioChannel;
	}
}
implementation {

	PROGMEM const char m_parameter_id[] = "radio_channel";

	task void radiochannel() {
		char id[sizeof(m_parameter_id)];
		uint8_t rc = call RadioChannel.getChannel();
		strcpy_P(id, m_parameter_id);
		signal DeviceParameter.value(id, DP_TYPE_UINT8, &rc, sizeof(rc));
	}

	command error_t DeviceParameter.set(void* value, uint8_t length) {
		if(length == sizeof(uint8_t)) {
			error_t err = call RadioChannel.setChannel(*(uint8_t*)value);
			if(err == EALREADY) {
				post radiochannel();
				return SUCCESS;
			}
			return err;
		}
		return EINVAL;
	}

	command error_t DeviceParameter.get() { return post radiochannel(); }

	command bool DeviceParameter.matches(const char* identifier) { return 0 == strcmp_P(identifier, m_parameter_id); }

	event void RadioChannel.setChannelDone() { post radiochannel(); }

}
