/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
#include "DeviceUUIDParameters.h"
configuration DeviceUUIDParametersC {}
implementation {

	components new DeviceUUIDParametersP();

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DeviceUUIDParametersP.DeviceParameter[DP_UUID_BOARD];
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DeviceUUIDParametersP.DeviceParameter[DP_UUID_PLATFORM];
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DeviceUUIDParametersP.DeviceParameter[DP_UUID_APPLICATION];

	components BoardUUIDC;
	DeviceUUIDParametersP.UUID[DP_UUID_BOARD] -> BoardUUIDC;

	components PlatformUUIDC;
	DeviceUUIDParametersP.UUID[DP_UUID_PLATFORM] -> PlatformUUIDC;

	components ApplicationUUIDC;
	DeviceUUIDParametersP.UUID[DP_UUID_APPLICATION] -> ApplicationUUIDC;

}
