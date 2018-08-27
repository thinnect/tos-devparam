/**
 * Control device LEDs.
 *
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
configuration LedsParameterC { }
implementation {

	components new LedsParameterP();

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> LedsParameterP.DeviceParameter;

	components LedsC;
	LedsParameterP.Leds -> LedsC;

}
