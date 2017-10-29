/**
 * Generic auth password parameter.
 *
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
generic module AuthPasswordParameterP() {
	provides {
		interface CheckAuth;
		interface DeviceParameter;
	}
	uses {
		interface NvParameter;
	}
}
implementation {

	PROGMEM const char m_auth_id[] = "auth_passwd";

	char m_auth[16] = { 0 };

	command bool CheckAuth.good(uint8_t* auth, uint8_t length) {
		if(call CheckAuth.empty() == FALSE) {
			if(length == sizeof(m_auth)) {
				return memcmp(auth, m_auth, sizeof(m_auth)) == 0;
			}
		}
		return FALSE;
	}

	command bool CheckAuth.empty() {
		uint8_t i;
		for(i=0;i<sizeof(m_auth);i++) {
			if(i != 0) {
				return FALSE;
			}
		}
		return TRUE;
	}

	task void responseTask() {
		char id[16+1];
		char v[16];
		uint8_t length = strnlen(m_auth, 16);
		strlcpy_P(id, m_auth_id, sizeof(id));
		memset(v, '*', length);
		signal DeviceParameter.value(id, DP_TYPE_STRING, v, length);
	}

	command error_t DeviceParameter.set(void* value, uint8_t length) {
		if(length <= sizeof(m_auth)) {
			char v[sizeof(m_auth)];
			memcpy(v, value, length);
			memset(v+length, 0, sizeof(v)-length);
			if(memcmp(m_auth, v, sizeof(m_auth)) != 0) {
				char id[16+1];
				strcpy_P(id, m_auth_id);
				if(call NvParameter.store(id, &v, sizeof(m_auth)) == SUCCESS) {
					memcpy(m_auth, v, sizeof(m_auth));
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
		return 0 == strcmp_P(identifier, m_auth_id);
	}

	command bool DeviceParameter.matches(const char* identifier) {
		return matches(identifier);
	}

	event bool NvParameter.matches(const char* identifier) {
		return matches(identifier);
	}

	event error_t NvParameter.init(void* value, uint8_t length) {
		if(length <= sizeof(m_auth)) {
			memcpy(m_auth, value, length);
			memset(m_auth+length, 0, sizeof(m_auth)-length);
			return SUCCESS;
		}
		return ESIZE;
	}

}
