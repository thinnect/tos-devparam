/**
 * Dummy NvParameterStorage. Pretends that items always get stored.
 *
 * @author Raido Pahtma
 * @license MIT
 */
generic module NvParameterStorageP(uint16_t storage_area_start, uint16_t storage_data_length, uint8_t total_parameters) {
	provides {
		interface Boot;
		interface NvParameter[uint8_t param];
	}
	uses {
		interface Boot as SysBoot;
		interface Boot as BadBoot;
		interface InternalFlash;
		interface Crc;
	}
}
implementation {

	#define __MODUUL__ "NvPS"
	#define __LOG_LEVEL__ ( LOG_LEVEL_NvParameterStorageP & BASE_LOG_LEVEL )
	#include "log.h"

	#warning "Using DUMMY NvParameterStorage"

	bool m_booted = FALSE;

	void booted() {
		if(!m_booted) {
			m_booted = TRUE;
			signal Boot.booted();
		}
	}

	event void SysBoot.booted() {
		booted();
	}

	event void BadBoot.booted() {
		booted();
	}

	command error_t NvParameter.store[uint8_t param](const char* identifier, void* pvalue, uint8_t vlen) {
		warn1("%p store %s", pvalue, vlen, NULL, identifier);
		return SUCCESS;
	}

}
