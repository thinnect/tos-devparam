/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
generic module GlobalPositioningSystemParameterP() {
	provides {
		interface Get<int32_t> as Latitude;
		interface Get<int32_t> as Longitude;
		interface DeviceParameter[uint8_t coord];
	}
	uses {
		interface NvParameter[uint8_t coord];
	}
}
implementation {

	PROGMEM const char m_latitude_id[] = "gps_latitude";
	PROGMEM const char m_longitude_id[] = "gps_longitude";

	int32_t m_gps[2] = {0, 0};
	uint8_t m_request = 0;

	command int32_t Latitude.get() {
		return m_gps[0];
	}

	command int32_t Longitude.get() {
		return m_gps[1];
	}

	char* parameterIdCopy(char* dest, uint8_t coord) {
		if(coord == 0) return strcpy_P(dest, m_latitude_id);
		if(coord == 1) return strcpy_P(dest, m_longitude_id);
		*dest = '\0';
		return dest;
	}

	task void coordinatetask() {
		nx_int32_t value;
		char id[16+1];
		value = m_gps[m_request];
		parameterIdCopy(id, m_request);
		signal DeviceParameter.value[m_request](id, DP_TYPE_INT32, &value, sizeof(value));
	}

	command error_t DeviceParameter.set[uint8_t coord](void* value, uint8_t length) {
		if(length == sizeof(nx_int32_t)) {
			int32_t gps = (int32_t)(*((nx_int32_t*)value));
			if(gps != m_gps[coord]) {
				char id[16+1];
				parameterIdCopy(id, coord);
				if(call NvParameter.store[coord](id, &gps, sizeof(gps)) == SUCCESS) {
					m_gps[coord] = gps;
					m_request = coord;
					post coordinatetask();
					return SUCCESS;
				}
				return ERETRY;
			}
			return EALREADY;
		}
		return EINVAL;
	}

	command error_t DeviceParameter.get[uint8_t coord]() {
		m_request = coord;
		return post coordinatetask();
	}

	bool matches(uint8_t coord, const char* identifier) {
		if(coord == 0) return 0 == strcmp_P(identifier, m_latitude_id);
		if(coord == 1) return 0 == strcmp_P(identifier, m_longitude_id);
		return FALSE;
	}

	command bool DeviceParameter.matches[uint8_t coord](const char* identifier) {
		return matches(coord, identifier);
	}

	event bool NvParameter.matches[uint8_t coord](const char* identifier) {
		return matches(coord, identifier);
	}

	event error_t NvParameter.init[uint8_t coord](void* value, uint8_t length) {
		if(length == sizeof(int32_t)) {
			m_gps[coord] = *((int32_t*)value);
			return SUCCESS;
		}
		return ESIZE;
	}

	default command error_t NvParameter.store[uint8_t coord](const char* identifier, void* pvalue, uint8_t vlen) {
		return ELAST;
	}

	default event void DeviceParameter.value[uint8_t coord](const char* identifier, uint8_t type, void* data, uint8_t length) { }
}
