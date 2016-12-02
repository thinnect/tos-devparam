/**
 * Non-volatile parameter storage.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#ifndef NVPARAMETERS_H_
#define NVPARAMETERS_H_

// NvParams UUID LL CC
typedef struct nvparams_storage_header {
	char storage_key[8]; // NvParams
	uint32_t uidhash; // uidhash of the software that wrote this storage area
	uint16_t length; // length of storage area (from the start of the header)
	uint16_t crc; // CRC of the header
} nvparams_storage_header_t;

#endif // NVPARAMETERS_H_
