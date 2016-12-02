/**
 * Serial communication setup for DeviceParameters.
 *
 * @author Raido Pahtma
 * @license MIT
 **/
configuration DeviceParametersSerialC { }
implementation {

	components DeviceParametersC;

	components SerialDispatcherC;
	DeviceParametersC.Send[0] -> SerialDispatcherC.Send[TOS_SERIAL_DEVICE_PARAMETERS_ID];
	DeviceParametersC.Receive[0] -> SerialDispatcherC.Receive[TOS_SERIAL_DEVICE_PARAMETERS_ID];

	components DeviceParametersSerialP;
	SerialDispatcherC.SerialPacketInfo[TOS_SERIAL_DEVICE_PARAMETERS_ID] -> DeviceParametersSerialP.SerialPacketInfo;

}
