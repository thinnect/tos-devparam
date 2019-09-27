/**
 * Configurable default RFPOWER parameter.
 *
 * @author Raido Pahtma
 * @license MIT
 */
configuration RFPowerParameterC { }
implementation {

	components new RFPowerParameterP();

	components RFA1DriverLayerP;
    RFPowerParameterP.SetTransmitPower -> RFA1DriverLayerP.SetTransmitPower;
    RFPowerParameterP.GetTransmitPower -> RFA1DriverLayerP.GetTransmitPower;

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> RFPowerParameterP.DeviceParameter;

	components new NvParameterC(sizeof(uint8_t));
	RFPowerParameterP.NvParameter -> NvParameterC.NvParameter;

}
