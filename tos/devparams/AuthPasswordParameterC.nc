/**
 * Generic auth password parameter.
 *
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
configuration AuthPasswordParameterC {
	provides interface CheckAuth;
}
implementation {

	components new AuthPasswordParameterP();
	CheckAuth = AuthPasswordParameterP.CheckAuth;

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> AuthPasswordParameterP.DeviceParameter;

	components new NvParameterC(16);
	AuthPasswordParameterP.NvParameter -> NvParameterC.NvParameter;

}
