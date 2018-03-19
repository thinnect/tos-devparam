/**
 * Output scaling parameters. Map 1-100 range to specified minv and maxv.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include "DeviceParameters.h"
configuration OutputScalingParametersC {
	provides interface Get<int8_t> as MinimumValue;
	provides interface Get<int8_t> as MaximumValue;
}
implementation {

	components new OutputScalingParametersP();
	MinimumValue = OutputScalingParametersP.MinimumValue;
	MaximumValue = OutputScalingParametersP.MaximumValue;

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> OutputScalingParametersP.DeviceParameter[0];
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> OutputScalingParametersP.DeviceParameter[1];

	components new NvParameterC(sizeof(int8_t)) as NvMinimumValue;
	OutputScalingParametersP.NvParameter[0] -> NvMinimumValue.NvParameter;

	components new NvParameterC(sizeof(int8_t)) as NvMaximumValue;
	OutputScalingParametersP.NvParameter[1] -> NvMaximumValue.NvParameter;

}
