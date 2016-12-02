/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
configuration AtmegaFuseParameterC { }
implementation {

	components new AtmegaFuseParameterP();

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> AtmegaFuseParameterP.HighFuse;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> AtmegaFuseParameterP.LowFuse;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> AtmegaFuseParameterP.ExtendedFuse;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> AtmegaFuseParameterP.LockFuse;

}
