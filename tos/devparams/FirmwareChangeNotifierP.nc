/**
 * Check stored IDENT_TIMESTAMP against current one,
 * notify other components if changed.
 *
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
generic module FirmwareChangeNotifierP() {
	provides {
		interface Boot as FirmwareChanged;
	}
	uses {
		interface NvParameter;
		interface Boot;
	}
}
implementation {

	#define __MODUUL__ "fwc"
	#define __LOG_LEVEL__ ( LOG_LEVEL_FirmwareChangeNotifierP & BASE_LOG_LEVEL )
	#include "log.h"

	PROGMEM const char m_parameter_id[] = "ident_timestamp";

	bool m_changed = TRUE;

	task void notifyTask() {
		error_t err __attribute__((unused));
		uint32_t timestamp = IDENT_TIMESTAMP;
		char id[16+1];

		signal FirmwareChanged.booted();

		strcpy_P(id, m_parameter_id);
		err = call NvParameter.store(id, &timestamp, sizeof(timestamp));
		logger(err == SUCCESS ? LOG_INFO1: LOG_ERR1, "new");
	}

	event void Boot.booted() {
		if(m_changed) {
			post notifyTask();
		}
	}

	bool matches(const char* identifier) {
		return 0 == strcmp_P(identifier, m_parameter_id);
	}

	event bool NvParameter.matches(const char* identifier) {
		return matches(identifier);
	}

	event error_t NvParameter.init(void* value, uint8_t length) {
		if(length == sizeof(uint32_t)) {
			uint32_t ts = *((uint32_t*)value);
			if(ts == IDENT_TIMESTAMP) {
				m_changed = FALSE;
			}
			return SUCCESS;
		}
		return ESIZE;
	}

}
