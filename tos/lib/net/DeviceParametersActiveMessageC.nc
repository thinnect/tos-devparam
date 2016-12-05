/**
 * ActiveMessage communication setup for DeviceParameters.
 *
 * It is possible to wire multiple radios or layers in parallel, by creating a
 * similar configuration. DP_INTERFACE_ID should be generated with the same
 * unique string in all such configuraitons. +1 must be added, because interface
 * id 0 is reserved for direct serial (may not be in use, but should not be used
 * for AM).
 *
 * @author Raido Pahtma
 * @license MIT
 **/
configuration DeviceParametersActiveMessageC { }
implementation {

	enum {
		DP_INTERFACE_ID = 1 + unique("DeviceParametersActiveMessageInterface")
	};

	components DeviceParametersC;

	components new AMResponseAdapterC();

	components new AMSenderC(0x80);
	AMResponseAdapterC.AMSend -> AMSenderC;
	AMResponseAdapterC.AMPacket -> AMSenderC;

	components new AMReceiverC(0x80);
	AMResponseAdapterC.AMReceive -> AMReceiverC;

	components SerialDispatcherC;
	DeviceParametersC.Send[DP_INTERFACE_ID] -> AMResponseAdapterC.Send;
	DeviceParametersC.Receive[DP_INTERFACE_ID] -> AMResponseAdapterC.Receive;

}
