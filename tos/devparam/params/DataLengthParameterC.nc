/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
configuration DataLengthParameterC { }
implementation {

	components new DataLengthParameterP();

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DataLengthParameterP.DeviceParameter;

}
