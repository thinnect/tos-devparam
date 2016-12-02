/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
configuration PersistentNodeIdParameterC { }
implementation {

	components new PersistentNodeIdParameterP();

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> PersistentNodeIdParameterP.DeviceParameter;

	components PersistentAddressC;
	PersistentNodeIdParameterP.Get -> PersistentAddressC.Get;
	PersistentNodeIdParameterP.Set -> PersistentAddressC.Set;

	components new TimerMilliC();
	PersistentNodeIdParameterP.Timer -> TimerMilliC;

}
