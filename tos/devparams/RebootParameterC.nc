/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
configuration RebootParameterC { }
implementation {

	components new RebootParameterP();

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> RebootParameterP.DeviceParameter;

	components new TimerMilliC();
	RebootParameterP.Timer -> TimerMilliC;

}
