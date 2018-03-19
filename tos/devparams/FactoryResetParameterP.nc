/**
 * Initiate factory reset procedure.
 *
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
generic module FactoryResetParameterP() {
	provides {
		interface DeviceParameter;
	}
	uses {
		interface Reset;
	}
}
implementation {

	PROGMEM const char m_parameter_id[] = "factory_reset";

	PROGMEM const char sts_no[] = "no";
	PROGMEM const char sts_yes[] = "yes";
	PROGMEM const char sts_done[] = "done";
	PROGMEM const char* const sts_table[] = { sts_no, sts_yes, sts_done };

	enum FactoryResetStates {
		FACTORY_RESET_STATE_NO,
		FACTORY_RESET_STATE_YES,
		FACTORY_RESET_STATE_DONE
	};

	uint8_t m_reset_state = FACTORY_RESET_STATE_NO;

	task void responseTask() {
		char id[sizeof(m_parameter_id)];
		char state[16];
		strcpy_P(id, m_parameter_id);
		strlcpy_P(state, (char*)pgm_read_word(&(sts_table[m_reset_state])), sizeof(state));
		signal DeviceParameter.value(id, DP_TYPE_STRING, state, strlen(state));
	}

	command error_t DeviceParameter.set(void* value, uint8_t length) {
		if(length == strlen_P(sts_yes)) {
			if(memcmp_P(value, sts_yes, strlen_P(sts_yes)) == 0) {
				if(call Reset.reset() == SUCCESS) {
					m_reset_state = FACTORY_RESET_STATE_YES;
					post responseTask();
				}
			}
			return SUCCESS;
		}
		return EINVAL;
	}

	event void Reset.resetDone(error_t result) {
		if(result == SUCCESS) {
			m_reset_state = FACTORY_RESET_STATE_DONE;
		}
		else {
			m_reset_state = FACTORY_RESET_STATE_NO;
		}
	}

	command error_t DeviceParameter.get() { return post responseTask(); }

	command bool DeviceParameter.matches(const char* identifier) { return 0 == strcmp_P(identifier, m_parameter_id); }

}
