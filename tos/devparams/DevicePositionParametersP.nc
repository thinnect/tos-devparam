/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
#include "DevicePositionParameters.h"
generic module DevicePositionParametersP() {
	provides {
		interface Get<int32_t>[uint8_t pos];
		interface DeviceParameter[uint8_t pos];
	}
	uses {
		interface NvParameter[uint8_t pos];
	}
}
implementation {

	PROGMEM const char m_latitude_id[]  = "gps_latitude";
	PROGMEM const char m_longitude_id[] = "gps_longitude";
	PROGMEM const char m_elevation_id[] = "elevation";
	PROGMEM const char m_northing_id[]  = "utm_northing";
	PROGMEM const char m_easting_id[]   = "utm_easting";
	PROGMEM const char m_pitch_id[]     = "rotation_pitch";
	PROGMEM const char m_yaw_id[]       = "rotation_yaw";
	PROGMEM const char m_roll_id[]      = "rotation_roll";

	int32_t m_positions[8] = {0, 0, 0, 0, 0, 0, 0, 0};
	uint8_t m_request = 0;

	command int32_t Get.get[uint8_t pos]() {
		return m_positions[pos];
	}

	char* parameterIdCopy(char* dest, uint8_t pos) {
		switch(pos) {
			case COORD_LATITUDE : return strcpy_P(dest, m_latitude_id);
			case COORD_LONGITUDE: return strcpy_P(dest, m_longitude_id);
			case COORD_ELEVATION: return strcpy_P(dest, m_elevation_id);
			case COORD_NORTHING : return strcpy_P(dest, m_northing_id);
			case COORD_EASTING  : return strcpy_P(dest, m_easting_id);
			case COORD_PITCH    : return strcpy_P(dest, m_pitch_id);
			case COORD_YAW      : return strcpy_P(dest, m_yaw_id);
			case COORD_ROLL     : return strcpy_P(dest, m_roll_id);
			default:
				*dest = '\0';
		}
		return dest;
	}

	task void responseTask() {
		nx_int32_t value;
		char id[16+1];
		value = m_positions[m_request];
		parameterIdCopy(id, m_request);
		signal DeviceParameter.value[m_request](id, DP_TYPE_INT32, &value, sizeof(value));
	}

	command error_t DeviceParameter.set[uint8_t pos](void* value, uint8_t length) {
		if(length == sizeof(nx_int32_t)) {
			int32_t position = (int32_t)(*((nx_int32_t*)value));
			if(position != m_positions[pos]) {
				char id[16+1];
				parameterIdCopy(id, pos);
				if(call NvParameter.store[pos](id, &position, sizeof(position)) == SUCCESS) {
					m_positions[pos] = position;
					m_request = pos;
					post responseTask();
					return SUCCESS;
				}
				return ERETRY;
			}
			m_request = pos;
			post responseTask();
			return SUCCESS;
		}
		return EINVAL;
	}

	command error_t DeviceParameter.get[uint8_t pos]() {
		m_request = pos;
		return post responseTask();
	}

	bool matches(uint8_t pos, const char* identifier) {
		switch(pos) {
			case COORD_LATITUDE : return 0 == strcmp_P(identifier, m_latitude_id);
			case COORD_LONGITUDE: return 0 == strcmp_P(identifier, m_longitude_id);
			case COORD_ELEVATION: return 0 == strcmp_P(identifier, m_elevation_id);
			case COORD_NORTHING : return 0 == strcmp_P(identifier, m_northing_id);
			case COORD_EASTING  : return 0 == strcmp_P(identifier, m_easting_id);
			case COORD_PITCH    : return 0 == strcmp_P(identifier, m_pitch_id);
			case COORD_YAW      : return 0 == strcmp_P(identifier, m_yaw_id);
			case COORD_ROLL     : return 0 == strcmp_P(identifier, m_roll_id);
		}
		return FALSE;
	}

	command bool DeviceParameter.matches[uint8_t pos](const char* identifier) {
		return matches(pos, identifier);
	}

	event bool NvParameter.matches[uint8_t pos](const char* identifier) {
		return matches(pos, identifier);
	}

	event error_t NvParameter.init[uint8_t pos](void* value, uint8_t length) {
		if(length == sizeof(int32_t)) {
			m_positions[pos] = *((int32_t*)value);
			return SUCCESS;
		}
		return ESIZE;
	}

	default command error_t NvParameter.store[uint8_t pos](const char* identifier, void* pvalue, uint8_t vlen) {
		return ELAST;
	}

	default event void DeviceParameter.value[uint8_t pos](const char* identifier, uint8_t type, void* data, uint8_t length) { }

}
