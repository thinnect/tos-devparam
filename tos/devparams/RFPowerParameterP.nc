/**
 * Configurable default RFPOWER parameter. Parameter itself is platform specific.
 *
 * @author Raido Pahtma
 * @license MIT
 */
generic module RFPowerParameterP() {
	provides {
		interface DeviceParameter;
	}
	uses {
		interface NvParameter;
		interface Set<uint8_t> as SetTransmitPower;
		interface Get<uint8_t> as GetTransmitPower;
	}
}
implementation {

	PROGMEM const char m_parameter_id[] = "rfpower";

	task void responseTask() {
		char id[16+1];
		uint8_t v = call GetTransmitPower.get();
		strcpy_P(id, m_parameter_id);
		signal DeviceParameter.value(id, DP_TYPE_UINT8, &v, sizeof(uint8_t));
	}

	command error_t DeviceParameter.set(void* value, uint8_t length) {
		if(length == sizeof(uint8_t)) {
			uint8_t v = *((uint8_t*)value);
			if(v != call GetTransmitPower.get()) {
				char id[16+1];
				strcpy_P(id, m_parameter_id);
				if(call NvParameter.store(id, &v, sizeof(v)) == SUCCESS) {
					call SetTransmitPower.set(v);
					post responseTask();
					return SUCCESS;
				}
				return ERETRY;
			}
			post responseTask();
			return SUCCESS;
		}
		return ESIZE;
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
		if(length == sizeof(uint8_t)) {
			call SetTransmitPower.set(*((uint8_t*)value));
			return SUCCESS;
		}
		return ESIZE;
	}

}
