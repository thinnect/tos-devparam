/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
configuration GlobalPositioningSystemParameterC {
	provides {
		interface Get<int32_t> as Latitude;
		interface Get<int32_t> as Longitude;
	}
}
implementation {

	components new GlobalPositioningSystemParameterP();
	Latitude = GlobalPositioningSystemParameterP.Latitude;
	Longitude = GlobalPositioningSystemParameterP.Longitude;

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> GlobalPositioningSystemParameterP.DeviceParameter[0];
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> GlobalPositioningSystemParameterP.DeviceParameter[1];

	components new NvParameterC(sizeof(int32_t)) as NvLatitude;
	GlobalPositioningSystemParameterP.NvParameter[0] -> NvLatitude.NvParameter;

	components new NvParameterC(sizeof(int32_t)) as NvLongitude;
	GlobalPositioningSystemParameterP.NvParameter[1] -> NvLongitude.NvParameter;

}
