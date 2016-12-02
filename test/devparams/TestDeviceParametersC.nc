/**
 * Small deviceparameters example.
 * @author Raido Pahtma
 * @license MIT
 */
#include "loglevels.h"
configuration TestDeviceParametersC { }
implementation {

	components UptimeParameterC;
	components RebootParameterC;

	components GlobalPositioningSystemParameterC;

	components BootInfoC;
	components MCUSRInfoC;

	components MainC;
	components new Boot2SplitControlC("b", "ser") as StartSerial;
	StartSerial.Boot -> MainC;

	components SerialActiveMessageC;
	StartSerial.SplitControl -> SerialActiveMessageC;

}
