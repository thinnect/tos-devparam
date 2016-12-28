/**
 * DeviceParameters handler for ActiveMessage and TOS_NODE_ID parameters.
 *
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
#include "ActiveMessageParameters.h"
configuration ActiveMessageParametersC {
	provides {
		interface Boot;
	}
	uses {
		interface Boot as SysBoot;
	}
}
implementation {

	components new ActiveMessageParametersP();
	ActiveMessageParametersP.SysBoot = SysBoot;
	Boot = ActiveMessageParametersP.Boot;

	components ActiveMessageAddressC;
	ActiveMessageParametersP.ActiveMessageAddress -> ActiveMessageAddressC;

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> ActiveMessageParametersP.DeviceParameter[DP_AMP_TOS_NODE_ID];
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> ActiveMessageParametersP.DeviceParameter[DP_AMP_AM_ADDR];
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> ActiveMessageParametersP.DeviceParameter[DP_AMP_AM_GROUP];

	components new NvParameterC(sizeof(uint16_t)) as NvTosNodeId;
	ActiveMessageParametersP.NvParameter[DP_AMP_TOS_NODE_ID] -> NvTosNodeId.NvParameter;

	components new NvParameterC(sizeof(am_addr_t)) as NvAmAddr;
	ActiveMessageParametersP.NvParameter[DP_AMP_AM_ADDR] -> NvAmAddr.NvParameter;

	components new NvParameterC(sizeof(am_group_t)) as NvAmGroup;
	ActiveMessageParametersP.NvParameter[DP_AMP_AM_GROUP] -> NvAmGroup.NvParameter;

}
