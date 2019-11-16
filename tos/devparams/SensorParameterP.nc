/**
 * Read sensor data into a device parameter.
 *
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"

PROGMEM const char g_sensorparameter_fmt[] = "sens_%s";

generic module SensorParameterP(char sensor_name[], typedef value_type @number()) {
	provides {
		interface DeviceParameter;
	}
	uses {
		interface Read<value_type>;
	}
}
implementation {

	command error_t DeviceParameter.get() {
		return call Read.read();
	}

	event void Read.readDone(error_t result, value_type value) {
		char id[sizeof(g_sensorparameter_fmt)+strlen(sensor_name)];
		sprintf_P(id, g_sensorparameter_fmt, sensor_name);

		if(result == SUCCESS) {
			nx_int32_t ivalue;
			ivalue = (nx_int32_t)value;
			signal DeviceParameter.value(id, DP_TYPE_INT32, &ivalue, sizeof(ivalue));
		}
		else {
			signal DeviceParameter.value(id, DP_TYPE_RAW, NULL, 0);
		}
	}

	command error_t DeviceParameter.set(void* value, uint8_t length) { return FAIL; }

	command bool DeviceParameter.matches(const char* identifier) {
		char id[sizeof(g_sensorparameter_fmt)+strlen(sensor_name)];
		sprintf_P(id, g_sensorparameter_fmt, sensor_name);
		return 0 == strcmp(identifier, id);
	}

}
