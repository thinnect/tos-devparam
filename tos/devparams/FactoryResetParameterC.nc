/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
configuration FactoryResetParameterC { }
implementation {

	components new FactoryResetParameterP();

	components FactoryResetC;
	FactoryResetParameterP.Reset -> FactoryResetC.Reset;

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> FactoryResetParameterP.DeviceParameter;

}
