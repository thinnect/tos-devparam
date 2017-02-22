/**
 * Generic output parameter wiring.
 *
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
configuration OutputParameterC {
	uses {
		interface Get<int32_t>;
		interface Set<int32_t>;
	}
}
implementation {

	components new OutputParameterP();
	OutputParameterP.Get = Get;
	OutputParameterP.Set = Set;

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> OutputParameterP.DeviceParameter;

}
