/**
 * Force filesystem format parameter.
 *
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
configuration FormatFilesystemParameterC {
	provides {
		interface Get<char>;
		interface Set<char>;
		interface GetSet<char>;
	}
}
implementation {

	components new FormatFilesystemParameterP();
	Get = FormatFilesystemParameterP.Get;
	Set = FormatFilesystemParameterP.Set;
	GetSet = FormatFilesystemParameterP.GetSet;

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> FormatFilesystemParameterP.DeviceParameter;

	components new NvParameterC(1);
	FormatFilesystemParameterP.NvParameter -> NvParameterC.NvParameter;

}
