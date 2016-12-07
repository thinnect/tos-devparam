/**
 * ActiveMessage communication setup for DeviceParameters.
 *
 * It is possible to wire multiple radios or layers in parallel, by creating a
 * similar configuration. Special interface id U
 *
 * @author Raido Pahtma
 * @license MIT
 **/
 #include "DeviceParameters.h"
configuration DeviceParametersActiveMessageC { }
implementation {

	enum {
		DP_INTERFACE_ID = UQ_DEVICE_PARAMETER_INTERFACE_ID
	};

	components DeviceParametersC;

	components new AMResponseAdapterC();
	DeviceParametersC.Send[DP_INTERFACE_ID] -> AMResponseAdapterC.Send;
	DeviceParametersC.Receive[DP_INTERFACE_ID] -> AMResponseAdapterC.Receive;

	components new AMSenderC(AMID_DEVICE_PARAMETERS);
	AMResponseAdapterC.AMSend -> AMSenderC;
	AMResponseAdapterC.AMPacket -> AMSenderC;

	components new AMReceiverC(AMID_DEVICE_PARAMETERS);
	AMResponseAdapterC.AMReceive -> AMReceiverC;

}
