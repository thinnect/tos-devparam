/**
 * User assigned "appliance" identificator.
 *
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
configuration DeviceApplianceParameterC { }
implementation {

	components new DeviceApplianceParameterP();

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> DeviceApplianceParameterP.DeviceParameter;

	components new NvParameterC(32);
	DeviceApplianceParameterP.NvParameter -> NvParameterC.NvParameter;

}
