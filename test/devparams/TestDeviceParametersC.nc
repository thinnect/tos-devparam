/**
 * Small deviceparameters example.
 * @author Raido Pahtma
 * @license MIT
 */
#include "loglevels.h"
configuration TestDeviceParametersC { }
implementation {

	components MainC;

	components UptimeParameterC;
	components RebootParameterC;

	components GlobalPositioningSystemParameterC;

	components BootInfoC;
	components MCUSRInfoC;

	components new TimerWatchdogC(5000);

	// Enable communication through serial interface
	components DeviceParametersSerialC;
	// Enable communication over radio
	components DeviceParametersActiveMessageC;

	components new Boot2SplitControlC("b", "seq");
	Boot2SplitControlC.Boot -> MainC;

	components new SeqSplitControlC("seq", "ser", "rdo");
	Boot2SplitControlC.SplitControl -> SeqSplitControlC;

	components SerialActiveMessageC; // TODO actually should start a lower layer?
	SeqSplitControlC.First -> SerialActiveMessageC;

	components new RadioChannelManagerC(DEFAULT_RADIO_CHANNEL);
	SeqSplitControlC.Second -> RadioChannelManagerC;

	components ActiveMessageC;
	RadioChannelManagerC.SubSplitControl -> ActiveMessageC.SplitControl;
	RadioChannelManagerC.SubRadioChannel -> ActiveMessageC.RadioChannel;

}
