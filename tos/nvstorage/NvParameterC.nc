/**
 * Non-volatile parameter storage instance module.
 *
 * @author Raido Pahtma
 * @license MIT
 */
generic configuration NvParameterC(uint8_t parameter_length) {
	provides interface NvParameter;
}
implementation {

	enum {
		NV_PARAMETER_ID = unique("NvParameter"),
		NV_PARAMETER_OFFSET = uniqueN("NvParameterDataLength", 1 + 16 + parameter_length + 2)
	};

	components NvParameterStorageC;
	NvParameter = NvParameterStorageC.NvParameter[NV_PARAMETER_ID];

}
