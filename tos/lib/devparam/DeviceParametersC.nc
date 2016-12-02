/**
 * @author Raido Pahtma
 * @license MIT
 **/
configuration DeviceParametersC {
	uses {
		interface DeviceParameter[uint8_t seqnum];
		interface Send[uint8_t iface];
		interface Receive[uint8_t iface];
	}
}
implementation {

	components new DeviceParametersP(DP_HEARTBEAT_PERIOD_S, uniqueCount("DeviceParameter"));
	DeviceParametersP.DeviceParameter = DeviceParameter;
	DeviceParametersP.Send = Send;
	DeviceParametersP.Receive = Receive;

	components MainC;
	DeviceParametersP.Boot -> MainC;

	components new TimerMilliC();
	DeviceParametersP.Timer -> TimerMilliC;

	components LocalIeeeEui64C;
	DeviceParametersP.LocalIeeeEui64 -> LocalIeeeEui64C;

	components LocalTimeSecondC;
	DeviceParametersP.LocalTimeSecond -> LocalTimeSecondC.LocalTime;

}
