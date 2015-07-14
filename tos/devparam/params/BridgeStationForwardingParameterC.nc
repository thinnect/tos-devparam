/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
configuration BridgeStationForwardingParameterC { }
implementation {

	components new BridgeStationForwardingParameterP();

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> BridgeStationForwardingParameterP.DeviceParameter;

	components BridgeStationC;
	BridgeStationForwardingParameterP.GetForwardAddress -> BridgeStationC.GetForwardAddress;
	BridgeStationForwardingParameterP.SetForwardAddress -> BridgeStationC.SetForwardAddress;

}
