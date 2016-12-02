/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
configuration UptimeParameterC { }
implementation {

	components new UptimeParameterP();

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> UptimeParameterP.DeviceParameter;

	components LocalTimeSecondC;
	UptimeParameterP.LocalTime -> LocalTimeSecondC;

}
