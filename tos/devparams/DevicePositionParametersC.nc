/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
#include "DevicePositionParameters.h"
configuration DevicePositionParametersC {
	provides {
		interface Get<int32_t> as Pitch;
		interface Get<int32_t> as Yaw;
		interface Get<int32_t> as Roll;

		interface Get<int32_t> as Latitude;
		interface Get<int32_t> as Longitude;
		interface Get<int32_t> as Elevation;

		interface Get<int32_t> as Northing;
		interface Get<int32_t> as Easting;
		interface Get<uint8_t> as Zone;
		interface Get<char> as Band;
	}
}
implementation {

	components new DevicePositionParametersP();
	Latitude  = DevicePositionParametersP.Get[COORD_LATITUDE];
	Longitude = DevicePositionParametersP.Get[COORD_LONGITUDE];
	Elevation = DevicePositionParametersP.Get[COORD_ELEVATION];
	Northing  = DevicePositionParametersP.Get[COORD_NORTHING];
	Easting   = DevicePositionParametersP.Get[COORD_EASTING];
	Pitch     = DevicePositionParametersP.Get[COORD_PITCH];
	Yaw       = DevicePositionParametersP.Get[COORD_YAW];
	Roll      = DevicePositionParametersP.Get[COORD_ROLL];

	components new DevicePositionUtmZoneParameterP();
	Zone = DevicePositionUtmZoneParameterP.Get;

	components new DevicePositionUtmBandParameterP();
	Band = DevicePositionUtmBandParameterP.Get;

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DevicePositionParametersP.DeviceParameter[COORD_LATITUDE];
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DevicePositionParametersP.DeviceParameter[COORD_LONGITUDE];
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DevicePositionParametersP.DeviceParameter[COORD_ELEVATION];
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DevicePositionParametersP.DeviceParameter[COORD_NORTHING];
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DevicePositionParametersP.DeviceParameter[COORD_EASTING];
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DevicePositionParametersP.DeviceParameter[COORD_PITCH];
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DevicePositionParametersP.DeviceParameter[COORD_YAW];
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DevicePositionParametersP.DeviceParameter[COORD_ROLL];
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DevicePositionUtmZoneParameterP.DeviceParameter;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DevicePositionUtmBandParameterP.DeviceParameter;

	components new NvParameterC(sizeof(int32_t)) as NvLatitude;
	DevicePositionParametersP.NvParameter[COORD_LATITUDE] -> NvLatitude.NvParameter;

	components new NvParameterC(sizeof(int32_t)) as NvLongitude;
	DevicePositionParametersP.NvParameter[COORD_LONGITUDE] -> NvLongitude.NvParameter;

	components new NvParameterC(sizeof(int32_t)) as NvElevation;
	DevicePositionParametersP.NvParameter[COORD_ELEVATION] -> NvElevation.NvParameter;

	components new NvParameterC(sizeof(int32_t)) as NvNorthing;
	DevicePositionParametersP.NvParameter[COORD_NORTHING] -> NvNorthing.NvParameter;

	components new NvParameterC(sizeof(int32_t)) as NvEasting;
	DevicePositionParametersP.NvParameter[COORD_EASTING] -> NvEasting.NvParameter;

	components new NvParameterC(sizeof(int32_t)) as NvPitch;
	DevicePositionParametersP.NvParameter[COORD_PITCH] -> NvPitch.NvParameter;

	components new NvParameterC(sizeof(int32_t)) as NvYaw;
	DevicePositionParametersP.NvParameter[COORD_YAW] -> NvYaw.NvParameter;

	components new NvParameterC(sizeof(int32_t)) as NvRoll;
	DevicePositionParametersP.NvParameter[COORD_ROLL] -> NvRoll.NvParameter;

	components new NvParameterC(sizeof(uint8_t)) as NvZone;
	DevicePositionUtmZoneParameterP.NvParameter -> NvZone.NvParameter;

	components new NvParameterC(sizeof(char)) as NvBand;
	DevicePositionUtmBandParameterP.NvParameter -> NvBand.NvParameter;

}
