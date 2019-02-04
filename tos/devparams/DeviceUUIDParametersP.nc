/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
#include "DeviceUUIDParameters.h"
generic module DeviceUUIDParametersP() {
	provides {
		interface DeviceParameter[uint8_t param];
	}
	uses {
		interface GetStruct<uuid_t> as UUID[uint8_t param];
	}
}
implementation {

	PROGMEM const char m_board_id[]  = "uuid_board";
	PROGMEM const char m_platform_id[] = "uuid_platform";
	PROGMEM const char m_application_id[] = "uuid_app";

	uint8_t m_request = 0;

	char* parameterIdCopy(char* dest, uint8_t param) {
		switch(param) {
			case DP_UUID_BOARD: return strcpy_P(dest, m_board_id);
			case DP_UUID_PLATFORM: return strcpy_P(dest, m_platform_id);
			case DP_UUID_APPLICATION: return strcpy_P(dest, m_application_id);
			default:
				*dest = '\0';
		}
		return dest;
	}

	task void responseTask() {
		uint8_t param;
		for(param=0;param<DP_UUID_COUNT;param++) {
			if(m_request & (1 << param)) {
				uuid_t huuid;
				nx_uuid_t nuuid;
				char id[16+1];
				parameterIdCopy(id, param);

				if(call UUID.get[param](&huuid) == SUCCESS) {
					hton_uuid(&nuuid, &huuid);
					signal DeviceParameter.value[param](id, DP_TYPE_RAW, &nuuid, sizeof(nuuid));
				}
				else {
					signal DeviceParameter.value[param](id, DP_TYPE_RAW, NULL, 0);
				}

				m_request &= ~(1 << param);
				if(m_request) {
					post responseTask();
				}
				return;
			}
		}
	}

	command error_t DeviceParameter.set[uint8_t param](void* value, uint8_t length) {
		return FAIL;
	}

	command error_t DeviceParameter.get[uint8_t param]() {
		if(m_request & (1 << param)) {
			return EALREADY;
		}
		m_request |= 1 << param;
		post responseTask();
		return SUCCESS;
	}

	bool matches(uint8_t pos, const char* identifier) {
		switch(pos) {
			case DP_UUID_BOARD : return 0 == strcmp_P(identifier, m_board_id);
			case DP_UUID_PLATFORM: return 0 == strcmp_P(identifier, m_platform_id);
			case DP_UUID_APPLICATION: return 0 == strcmp_P(identifier, m_application_id);
		}
		return FALSE;
	}

	command bool DeviceParameter.matches[uint8_t param](const char* identifier) {
		return matches(param, identifier);
	}

	default event void DeviceParameter.value[uint8_t param](const char* identifier, uint8_t type, void* data, uint8_t length) { }

	default command error_t UUID.get[uint8_t param](uuid_t* uuid) { return FAIL; }

}
