/**
 * Count filesystem failures. Up to 255. Reset when firmware is changed.
 *
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
configuration FilesystemFailureCountParameterC {
	provides {
		interface Get<uint8_t>;
		interface Set<uint8_t>;
		interface GetSet<uint8_t>;
		interface IncrementDecrement<uint8_t>;
	}
}
implementation {

	components new FilesystemFailureCountParameterP();
	Get = FilesystemFailureCountParameterP.Get;
	Set = FilesystemFailureCountParameterP.Set;
	GetSet = FilesystemFailureCountParameterP.GetSet;
	IncrementDecrement = FilesystemFailureCountParameterP.IncrementDecrement;

	components FirmwareChangeNotifierC;
	FilesystemFailureCountParameterP.FirmwareChanged -> FirmwareChangeNotifierC.FirmwareChanged;

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> FilesystemFailureCountParameterP.DeviceParameter;

	components new NvParameterC(1);
	FilesystemFailureCountParameterP.NvParameter -> NvParameterC.NvParameter;

}
