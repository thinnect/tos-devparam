/**
 * Serial communication setup for DeviceParameters.
 *
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
configuration DeviceParametersSerialC { }
implementation {

	components DeviceParametersC;

	components SerialDispatcherC;
	DeviceParametersC.Send[DP_HEARTBEAT_INTERFACE_ID] -> SerialDispatcherC.Send[TOS_SERIAL_DEVICE_PARAMETERS_ID];
	DeviceParametersC.Receive[DP_HEARTBEAT_INTERFACE_ID] -> SerialDispatcherC.Receive[TOS_SERIAL_DEVICE_PARAMETERS_ID];

	components DeviceParametersSerialP;
	SerialDispatcherC.SerialPacketInfo[TOS_SERIAL_DEVICE_PARAMETERS_ID] -> DeviceParametersSerialP.SerialPacketInfo;

}
