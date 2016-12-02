/**
 * Non-volatile parameter storage test MainC.
 * Initializes logging before starting storage.
 * @author Raido Pahtma
 * @license MIT
 */
#include "hardware.h"
configuration MainC {
	provides interface Boot;
	uses interface Init as SoftwareInit;
}
implementation {

	#warning "testnvparameters MainC"

	components RealMainP;
	SoftwareInit = RealMainP.SoftwareInit;

	components PlatformC;
	RealMainP.PlatformInit -> PlatformC;

	components TinySchedulerC;
	RealMainP.Scheduler -> TinySchedulerC;

	#if (defined(PRINTF_PORT) && !defined(TOSSIM))
		#warning "PRINTF enabled"
		#ifndef START_PRINTF_DELAY
			#warning "default START_PRINTF_DELAY 1024"
			#define START_PRINTF_DELAY 1024
		#endif
		components new StartPrintfC(START_PRINTF_DELAY) as Logging;
	#else
		components new DummyBootC() as Logging;
	#endif
		Logging.SysBoot -> RealMainP.Boot;

	components NvParameterStorageC;
	NvParameterStorageC.SysBoot -> Logging.Boot;

	Boot = NvParameterStorageC.Boot;

}
