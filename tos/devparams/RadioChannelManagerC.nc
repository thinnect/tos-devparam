/**
 * Wrap ActiveMessage and handle initial channel configuration and subsequent
 * channel changes from external commands and other modules through the
 * RadioChannel interface.
 *
 * @author Raido Pahtma
 * @license MIT
 */
generic configuration RadioChannelManagerC(uint8_t default_radio_channel) {
	provides {
		interface SplitControl;
		interface RadioChannel;
	}
	uses {
		interface SplitControl as SubSplitControl;
		interface RadioChannel as SubRadioChannel;
	}
}
implementation {

	components new RadioChannelManagerP(default_radio_channel) as Module;

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> Module.DefaultChannelParameter;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> Module.CurrentChannelParameter;

	SplitControl = Module.SplitControl;
	RadioChannel = Module.RadioChannel;

	Module.SubSplitControl = SubSplitControl;
	Module.SubRadioChannel = SubRadioChannel;

	components new NvParameterC(sizeof(uint8_t));
	Module.StoredRadioChannel -> NvParameterC.NvParameter;

}