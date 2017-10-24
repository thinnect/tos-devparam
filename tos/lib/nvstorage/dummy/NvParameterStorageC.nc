/**
 * Dummy NvParameterStorage. Pretends that items always get stored.
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

	#warning "Using DUMMY NvParameterStorage"

	components new NvParameterStorageP(0,
	                                   uniqueCount("NvParameterDataLength"),
	                                   uniqueCount("NvParameter"));
	Boot = NvParameterStorageP.Boot;
	NvParameter = NvParameterStorageP.NvParameter;
	NvParameterStorageP.SysBoot = SysBoot;
	NvParameterStorageP.BadBoot = BadBoot;

}
