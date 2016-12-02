/**
 * @author Raido Pahtma
 * @license MIT
 **/
configuration DeviceParametersC {
	uses {
		interface DeviceParameter[uint8_t seqnum];
	}
}
implementation {

	components new DeviceParametersP(DP_HEARTBEAT_PERIOD_S, uniqueCount("DeviceParameter"));
	DeviceParametersP.DeviceParameter = DeviceParameter;

	components MainC;
	DeviceParametersP.Boot -> MainC;

	components new TimerMilliC();
	DeviceParametersP.Timer -> TimerMilliC;

	components SerialDispatcherC;
	DeviceParametersP.Send[0] -> SerialDispatcherC.Send[TOS_SERIAL_DEVICE_PARAMETERS_ID];
	DeviceParametersP.Receive[0] -> SerialDispatcherC.Receive[TOS_SERIAL_DEVICE_PARAMETERS_ID];
	SerialDispatcherC.SerialPacketInfo[TOS_SERIAL_DEVICE_PARAMETERS_ID] -> DeviceParametersP.SerialPacketInfo;

	components LocalIeeeEui64C;
	DeviceParametersP.LocalIeeeEui64 -> LocalIeeeEui64C;

	components LocalTimeSecondC;
	DeviceParametersP.LocalTimeSecond -> LocalTimeSecondC.LocalTime;

}
