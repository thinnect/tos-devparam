/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
generic configuration SensorParameterC(char sensor_name[], typedef value_type @number()) {
	uses {
		interface Read<value_type>;
	}
}
implementation {

	components new SensorParameterP(sensor_name, value_type);
	SensorParameterP.Read = Read;

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> SensorParameterP.DeviceParameter;

}
