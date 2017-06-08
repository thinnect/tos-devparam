/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
configuration BootsParameterC { }
implementation {

	components new BootsParameterP();

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> BootsParameterP.DeviceParameter;

	components BootsLifetimeC;
	BootsParameterP.Boots -> BootsLifetimeC.BootNumber;

}
