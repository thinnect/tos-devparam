/**
 * Output scaling parameters. Map 1-100 range to specified minv and maxv.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include "DeviceParameters.h"
generic module OutputScalingParametersP() {
	provides {
		interface Get<int8_t> as MinimumValue;
		interface Get<int8_t> as MaximumValue;
		interface DeviceParameter[uint8_t param];
	}
	uses {
		interface NvParameter[uint8_t param];
	}
}
implementation {

	PROGMEM const char m_minv_id[] = "output_minv";
	PROGMEM const char m_maxv_id[] = "output_maxv";

	#ifndef OUTPUT_MINIMUM_VALUE
	#define OUTPUT_MINIMUM_VALUE 1
	#endif//OUTPUT_MINIMUM_VALUE

	#ifndef OUTPUT_MAXIMUM_VALUE
	#define OUTPUT_MAXIMUM_VALUE 100
	#endif//OUTPUT_MAXIMUM_VALUE

	int8_t m_minv = OUTPUT_MINIMUM_VALUE;
	int8_t m_maxv = OUTPUT_MAXIMUM_VALUE;

	uint8_t m_request = 0;

	command int8_t MinimumValue.get() {
		return m_minv;
	}

	command int8_t MaximumValue.get() {
		return m_maxv;
	}

	char* parameterIdCopy(char* dest, uint8_t param) {
		switch(param) {
			case 0: return strcpy_P(dest, m_minv_id);
			case 1: return strcpy_P(dest, m_maxv_id);
			default:
				*dest = '\0';
		}
		return dest;
	}

	task void responseTask() {
		uint8_t param;
		for(param=0;param<2;param++) {
			if(m_request & (1 << param)) {
				char id[16+1];
				parameterIdCopy(id, param);
				if(param == 0) {
					signal DeviceParameter.value[param](id, DP_TYPE_INT8, &m_minv, sizeof(int8_t));
				}
				else if(param == 1) {
					signal DeviceParameter.value[param](id, DP_TYPE_INT8, &m_maxv, sizeof(int8_t));
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
		if(length == sizeof(int8_t)) {
			char id[16+1];
			int8_t* val = NULL;
			int8_t v = *((int8_t*)value);
			switch(param) {
				case 0:
					if((v > m_maxv)||(v < 1)) {
						return EINVAL;
					}
					val = &m_minv;
					strcpy_P(id, m_minv_id);
				break;
				case 1:
					if((v < m_minv)||(v > 100)) {
						return EINVAL;
					}
					val = &m_maxv;
					strcpy_P(id, m_maxv_id);
				break;
				default:
					return FAIL;
			}

			if(v != *val) {
				if(call NvParameter.store[param](id, &v, sizeof(v)) != SUCCESS) {
					return ERETRY;
				}
				*val = v;
			}
			m_request |= 1 << param;
			post responseTask();
			return SUCCESS;
		}
		return ESIZE;
	}

	command error_t DeviceParameter.get[uint8_t param]() {
		m_request |= 1 << param;
		return post responseTask();
	}

	bool matches(uint8_t param, const char* identifier) {
		switch(param) {
			case 0: return 0 == strcmp_P(identifier, m_minv_id);
			case 1: return 0 == strcmp_P(identifier, m_maxv_id);
		}
		return FALSE;
	}

	command bool DeviceParameter.matches[uint8_t param](const char* identifier) {
		return matches(param, identifier);
	}

	default event void DeviceParameter.value[uint8_t param](const char* identifier, uint8_t type, void* data, uint8_t length) { }

	event bool NvParameter.matches[uint8_t param](const char* identifier) {
		return matches(param, identifier);
	}

	event error_t NvParameter.init[uint8_t param](void* value, uint8_t length) {
		if(length == sizeof(int8_t)) {
			switch(param) {
				case 0:
					m_minv = *((int8_t*)value);
				break;
				case 1:
					m_maxv = *((int8_t*)value);
				break;
				default:
					return EINVAL;
			}
			return SUCCESS;
		}
		return ESIZE;
	}

	default command error_t NvParameter.store[uint8_t param](const char* identifier, void* pvalue, uint8_t vlen) { return ELAST; }

}

