/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
configuration LowPowerListeningParametersC { }
implementation {

	components new LowPowerListeningParametersP();

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> LowPowerListeningParametersP.RemoteWakeup;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> LowPowerListeningParametersP.LocalWakeup;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> LowPowerListeningParametersP.Delay;

	components ActiveMessageC;
	LowPowerListeningParametersP.LowPowerListening -> ActiveMessageC;

	components SystemLowPowerListeningC;
	LowPowerListeningParametersP.SystemLowPowerListening -> SystemLowPowerListeningC;

}
