/**
 * Notify when first booting a different firmware.
 *
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
configuration FirmwareChangeNotifierC {
	provides {
		interface Boot as FirmwareChanged;
	}
}
implementation {

	components new FirmwareChangeNotifierP();
	FirmwareChanged = FirmwareChangeNotifierP.FirmwareChanged;

	components MainC;
	FirmwareChangeNotifierP.Boot -> MainC.Boot;

	components new NvParameterC(sizeof(uint32_t));
	FirmwareChangeNotifierP.NvParameter -> NvParameterC.NvParameter;

}
