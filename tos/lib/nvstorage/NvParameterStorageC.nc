/**
 * Non-volatile parameter storage in InternalFlash (EEPROM).
 *
 * @author Raido Pahtma
 * @license MIT
 */
configuration NvParameterStorageC {
	provides {
		interface Boot;
		interface NvParameter[uint8_t param];
	}
	uses {
		interface Boot as SysBoot;
		interface Boot as BadBoot;
	}
}
implementation {

	#ifndef NVPARAMETER_STORAGE_ADDRESS
	#warning NVPARAMETER_STORAGE_ADDRESS 1024
	#define NVPARAMETER_STORAGE_ADDRESS 1024
	#endif // NVPARAMETER_STORAGE_ADDRESS

	components new NvParameterStorageP(NVPARAMETER_STORAGE_ADDRESS,
	                                   uniqueCount("NvParameterDataLength"),
	                                   uniqueCount("NvParameter"));
	Boot = NvParameterStorageP.Boot;
	NvParameter = NvParameterStorageP.NvParameter;
	NvParameterStorageP.SysBoot = SysBoot;
	NvParameterStorageP.BadBoot = BadBoot;

	components InternalFlashC;
	NvParameterStorageP.InternalFlash -> InternalFlashC;

	components CrcC;
	NvParameterStorageP.Crc -> CrcC;

}
