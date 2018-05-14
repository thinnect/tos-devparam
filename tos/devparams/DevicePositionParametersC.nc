/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
#include "DevicePositionParameters.h"
configuration DevicePositionParametersC {
	provides {
		// Get interfaces
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

		interface Get<char> as FixType;

		// Set interfaces
		interface Set<int32_t> as SetPitch;
		interface Set<int32_t> as SetYaw;
		interface Set<int32_t> as SetRoll;

		interface Set<int32_t> as SetLatitude;
		interface Set<int32_t> as SetLongitude;
		interface Set<int32_t> as SetElevation;

		interface Set<int32_t> as SetNorthing;
		interface Set<int32_t> as SetEasting;
		interface Set<uint8_t> as SetZone;
		interface Set<char> as SetBand;

		interface Set<char> as SetFixType;

		// Save interfaces
		interface Set<int32_t> as SavePitch;
		interface Set<int32_t> as SaveYaw;
		interface Set<int32_t> as SaveRoll;

		interface Set<int32_t> as SaveLatitude;
		interface Set<int32_t> as SaveLongitude;
		interface Set<int32_t> as SaveElevation;

		interface Set<int32_t> as SaveNorthing;
		interface Set<int32_t> as SaveEasting;
		interface Set<uint8_t> as SaveZone;
		interface Set<char> as SaveBand;

		interface Set<char> as SaveFixType;
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

	SetLatitude  = DevicePositionParametersP.Set[COORD_LATITUDE];
	SetLongitude = DevicePositionParametersP.Set[COORD_LONGITUDE];
	SetElevation = DevicePositionParametersP.Set[COORD_ELEVATION];
	SetNorthing  = DevicePositionParametersP.Set[COORD_NORTHING];
	SetEasting   = DevicePositionParametersP.Set[COORD_EASTING];
	SetPitch     = DevicePositionParametersP.Set[COORD_PITCH];
	SetYaw       = DevicePositionParametersP.Set[COORD_YAW];
	SetRoll      = DevicePositionParametersP.Set[COORD_ROLL];

	SaveLatitude  = DevicePositionParametersP.Save[COORD_LATITUDE];
	SaveLongitude = DevicePositionParametersP.Save[COORD_LONGITUDE];
	SaveElevation = DevicePositionParametersP.Save[COORD_ELEVATION];
	SaveNorthing  = DevicePositionParametersP.Save[COORD_NORTHING];
	SaveEasting   = DevicePositionParametersP.Save[COORD_EASTING];
	SavePitch     = DevicePositionParametersP.Save[COORD_PITCH];
	SaveYaw       = DevicePositionParametersP.Save[COORD_YAW];
	SaveRoll      = DevicePositionParametersP.Save[COORD_ROLL];

	components new DevicePositionUtmZoneParameterP();
	Zone = DevicePositionUtmZoneParameterP.Get;
	SetZone = DevicePositionUtmZoneParameterP.Set;
	SaveZone = DevicePositionUtmZoneParameterP.Save;

	components new DevicePositionUtmBandParameterP();
	Band = DevicePositionUtmBandParameterP.Get;
	SetBand = DevicePositionUtmBandParameterP.Set;
	SaveBand = DevicePositionUtmBandParameterP.Save;

	components new DevicePositionFixTypeParameterP();
	FixType = DevicePositionFixTypeParameterP.Get;
	SetFixType = DevicePositionFixTypeParameterP.Set;
	SaveFixType = DevicePositionFixTypeParameterP.Save;

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DevicePositionFixTypeParameterP.DeviceParameter;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DevicePositionParametersP.DeviceParameter[COORD_LATITUDE];
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DevicePositionParametersP.DeviceParameter[COORD_LONGITUDE];
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DevicePositionParametersP.DeviceParameter[COORD_NORTHING];
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DevicePositionParametersP.DeviceParameter[COORD_EASTING];
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DevicePositionUtmZoneParameterP.DeviceParameter;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DevicePositionUtmBandParameterP.DeviceParameter;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DevicePositionParametersP.DeviceParameter[COORD_ELEVATION];
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DevicePositionParametersP.DeviceParameter[COORD_PITCH];
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DevicePositionParametersP.DeviceParameter[COORD_YAW];
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DevicePositionParametersP.DeviceParameter[COORD_ROLL];

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

	components new NvParameterC(sizeof(char)) as NvFixType;
	DevicePositionFixTypeParameterP.NvParameter -> NvFixType.NvParameter;

}
