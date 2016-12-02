/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
configuration RadioChannelParameterC { }
implementation {

	components new RadioChannelParameterP();

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> RadioChannelParameterP.DeviceParameter;

	components RadioChannelOffFixP;
	RadioChannelParameterP.RadioChannel -> RadioChannelOffFixP.RadioChannel;

	components ActiveMessageC;
	RadioChannelOffFixP.RadioControl -> ActiveMessageC.SplitControl;
	RadioChannelOffFixP.RealRadioChannel -> ActiveMessageC.RadioChannel;

}
