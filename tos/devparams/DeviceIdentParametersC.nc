/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
configuration DeviceIdentParametersC { }
implementation {

	components new DeviceIdentParametersP();

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DeviceIdentParametersP.Eui64;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DeviceIdentParametersP.Boardname;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DeviceIdentParametersP.Appname;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DeviceIdentParametersP.Uidhash;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DeviceIdentParametersP.Timestamp;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DeviceIdentParametersP.SwVersion;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DeviceIdentParametersP.PcbVersion;

	components LocalIeeeEui64C;
	DeviceIdentParametersP.LocalIeeeEui64 -> LocalIeeeEui64C;

}
