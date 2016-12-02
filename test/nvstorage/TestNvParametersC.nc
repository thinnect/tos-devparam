/**
 * Non-volatile parameter storage test configuration.
 * @author Raido Pahtma
 * @license MIT
 */
#include "logger.h"
configuration TestNvParametersC { }
implementation {

	components TestNvParametersP as Test;

	components new NvParameterC(1) as P8;
	Test.Param8 -> P8.NvParameter;

	components new NvParameterC(2) as P16;
	Test.Param16 -> P16.NvParameter;

	components new NvParameterC(4) as P32;
	Test.Param32 -> P32.NvParameter;

	components MainC;
	Test.Boot -> MainC;

}
