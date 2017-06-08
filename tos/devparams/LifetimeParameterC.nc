/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
configuration LifetimeParameterC { }
implementation {

	components new LifetimeParameterP();

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> LifetimeParameterP.DeviceParameter;

	components BootsLifetimeC;
	LifetimeParameterP.Lifetime -> BootsLifetimeC.Lifetime;

}
