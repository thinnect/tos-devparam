/**
 * Non-volatile parameter storage test module.
 * @author Raido Pahtma
 * @license MIT
 */
module TestNvParametersP {
	uses {
		interface NvParameter as Param8;
		interface NvParameter as Param16;
		interface NvParameter as Param32;
		interface Boot;
	}
}
implementation {

	#define __MODUUL__ "test"
	#define __LOG_LEVEL__ ( LOG_LEVEL_TestNvParametersP & BASE_LOG_LEVEL )
	#include "log.h"

	PROGMEM const char m_p8_id[] = "uint8_t";
	PROGMEM const char m_p16_id[] = "uint16_t";
	PROGMEM const char m_p32_id[] = "uint32_t";

	uint8_t m_p8 = 0;
	uint16_t m_p16 = 0;
	uint32_t m_p32 = 0;

	event bool Param8.matches(const char* identifier) {
		int match = strcmp_P(identifier, m_p8_id);
		debug1("match '%s' == %d", identifier, match);
		return match == 0;
	}
	event error_t Param8.init(void* pvalue, uint8_t vlen) {
		debugb1("init %u", pvalue, vlen, vlen);
		if(vlen == sizeof(uint8_t)) {
			m_p8 = *((uint8_t*)pvalue);
			return SUCCESS;
		}
		return ESIZE;
	}

	event bool Param16.matches(const char* identifier) {
		int match = strcmp_P(identifier, m_p16_id);
		debug1("match '%s' == %d", identifier, match);
		return match == 0;
	}
	event error_t Param16.init(void* pvalue, uint8_t vlen) {
		debugb1("init %u", pvalue, vlen, vlen);
		if(vlen == sizeof(uint16_t)) {
			m_p16 = *((uint16_t*)pvalue);
			return SUCCESS;
		}
		return ESIZE;
	}

	event bool Param32.matches(const char* identifier) {
		int match = strcmp_P(identifier, m_p32_id);
		debug1("match '%s' == %d", identifier, match);
		return match == 0;
	}
	event error_t Param32.init(void* pvalue, uint8_t vlen) {
		debugb1("init %u", pvalue, vlen, vlen);
		if(vlen == sizeof(uint32_t)) {
			m_p32 = *((uint32_t*)pvalue);
			return SUCCESS;
		}
		return ESIZE;
	}

	event void Boot.booted() {
		error_t rp8, rp16, rp32;
		char p8_id[strlen_P(m_p8_id)];
		char p16_id[strlen_P(m_p16_id)];
		char p32_id[strlen_P(m_p32_id)];
		strcpy_P(p8_id, m_p8_id);
		strcpy_P(p16_id, m_p16_id);
		strcpy_P(p32_id, m_p32_id);

		info1("%02"PRIx8" %04"PRIx16" %08"PRIx32, m_p8, m_p16, m_p32);

		m_p8++;
		m_p16++;
		m_p32++;

		rp8  = call Param8.store(p8_id,  (uint8_t*)&m_p8,  sizeof(m_p8));
		rp16 = call Param8.store(p16_id, (uint8_t*)&m_p16, sizeof(m_p16));
		rp32 = call Param8.store(p32_id, (uint8_t*)&m_p32, sizeof(m_p32));

		info1("%u %u %u", rp8, rp16, rp32);
	}

}
