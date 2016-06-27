/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
configuration RealTimeClockParameterC {
	uses interface Set<uint32_t> as SetNetworkTimeOffset;
}
implementation {

	components new RealTimeClockParameterP();
	RealTimeClockParameterP.SetNetworkTimeOffset = SetNetworkTimeOffset;

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> RealTimeClockParameterP.DeviceParameter;

	components RealTimeClockC;
	RealTimeClockParameterP.RealTimeClock -> RealTimeClockC;

	components LocalTimeSecondC;
	RealTimeClockParameterP.LocalTimeSecond -> LocalTimeSecondC;

}
