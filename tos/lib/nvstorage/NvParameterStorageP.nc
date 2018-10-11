/**
 * Non-volatile parameter storage in InternalFlash (EEPROM).
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include <avr/wdt.h>
#include "NvParameters.h"
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

	enum NvParameterStorageEnum {
		NVPARAMS_DATA_START = storage_area_start + 2*sizeof(nvparams_storage_header_t),
		NVPARAMS_DATA_END = NVPARAMS_DATA_START + storage_data_length,
		NVPARAMS_MIN_ELEMENT_SIZE = 16 + 1 + 2, // name(16) + value(>=1) + CRC(2)
		NVPARAMS_MAX_ELEMENT_SIZE = 255 - 16 - 2
	};

	enum NvParameterStates {
		ST_OFF,
		ST_BADBOOT,
		ST_ACTIVE
	};

	PROGMEM const char storage_header_key[] = "NvParams";

	uint8_t m_state = ST_OFF;

	void internalFlash_erase(void* addr, uint16_t length) {
		uint8_t ff = 0xFF;
		uint8_t* erase_addr = addr;
		for(;erase_addr<(uint8_t*)addr+length;erase_addr++) {
			wdt_reset();
			call InternalFlash.write(erase_addr, &ff, 1);
		}
	}

	error_t internalFlash_copy(void* dest, void* source, uint16_t length) {
		uint8_t buffer[length];
		wdt_reset();
		if(call InternalFlash.read(source, buffer, length) == SUCCESS) {
			return call InternalFlash.write(dest, buffer, length);
		}
		return FAIL;
	}

	error_t loadHeader(nvparams_storage_header_t* hdr, uint16_t address) {
		wdt_reset();
		if(call InternalFlash.read((void*)address, hdr, sizeof(nvparams_storage_header_t)) == SUCCESS) {
			uint16_t crc = call Crc.crc16(hdr, sizeof(nvparams_storage_header_t) - 2);
			if(crc == hdr->crc) {
				if(strncmp_P(hdr->storage_key, storage_header_key, strlen_P(storage_header_key)) == 0) {
					return SUCCESS;
				}
				else warn1("hdr key");
			}
			else warn1("hdr crc %p", (void*)address);
		}
		return FAIL;
	}

	// L NNNNNNNNNNNNNNNN V..V CC
	error_t storeParameter(void* addr, const char* name, void* value, uint8_t vlen) {
		uint16_t crc;
		uint8_t buffer[1+16+vlen+2];
		buffer[0] = sizeof(buffer) - 1;
		strncpy((char*)(&buffer[1]), name, 16);
		memcpy(&buffer[1+16], value, vlen);
		crc = call Crc.crc16(buffer, sizeof(buffer)-2);
		buffer[sizeof(buffer)-1] = (uint8_t)(crc >> 8);
		buffer[sizeof(buffer)-2] = (uint8_t)(crc);
		debugb1("%p store %s", buffer, sizeof(buffer), addr, name);
		wdt_reset();
		return call InternalFlash.write(addr, buffer, sizeof(buffer));
	}

	uint8_t loadParameter(void* addr, char name[16+1], void* value, uint8_t* vlen) {
		uint8_t tlen;
		wdt_reset();
		if(call InternalFlash.read(addr, &tlen, 1) == SUCCESS) {
			if((NVPARAMS_MIN_ELEMENT_SIZE <= tlen) && (tlen <= NVPARAMS_MAX_ELEMENT_SIZE)) {
				uint8_t buffer[1+tlen];
				wdt_reset();
				if(call InternalFlash.read(addr, buffer, sizeof(buffer)) == SUCCESS) {
					uint16_t crc = (((uint16_t)buffer[sizeof(buffer)-1])<<8) | (uint16_t)(buffer[sizeof(buffer)-2]);
					debugb1("%p load", buffer, sizeof(buffer), addr);
					if(call Crc.crc16(buffer, sizeof(buffer)-2) == crc) {
						strncpy(name, (char*)(&buffer[1]), 16);
						name[16] = '\0';

						if(vlen != NULL) {
							*vlen = tlen - 16 - 2;
							if(value != NULL) {
								memcpy(value, &buffer[1+16], *vlen);
							}
						}

						return tlen + 1;
					}
					else warn1("%p crc", addr);
				}
				else warn2("%p read", addr);
			}
			else if(tlen != 0xFF) warn3("%p bad tlen %u", addr, tlen);
			else debug3("%p empty", addr);
		}
		else warn2("%p read", addr);

		return 0;
	}

	uint16_t loadAllValues(uint16_t storage_addr, uint16_t storage_size) {
		char name[16+1];
		uint8_t value[255];
		uint8_t length = 0;

		uint16_t eaddr = storage_addr;
		uint16_t saddr = storage_addr;
		while(saddr < (storage_addr+storage_size-NVPARAMS_MIN_ELEMENT_SIZE)) {
			uint8_t plen = loadParameter((void*)saddr, name, value, &length);
			if(plen > 0) { // Loaded something useful
				bool match = FALSE;
				uint8_t param;
				for(param=0;param<total_parameters;param++) {
					wdt_reset();
					if(signal NvParameter.matches[param](name)) {
						if(signal NvParameter.init[param](value, length) == SUCCESS) {
							debugb1("init %s", value, length, name);
							match = TRUE;
						}
						else warnb1("init %s", value, length, name);
						break;
					}
				}

				#ifdef NVPARAMS_STORAGE_NO_MIGRATION
				#warning NVPARAMS_STORAGE_NO_MIGRATION
				// Never discard variables. intended for recovery/migration builds
				// that need access to some variables, but do not implement all
				// variables used for normal builds
				match = TRUE;
				#endif//NVPARAMS_STORAGE_NO_MIGRATION

				if(match) {
					if(eaddr != saddr) { // There is a gap (for some reason)
						info1("move %p->%p %u", (void*)saddr, (void*)eaddr, plen);
						internalFlash_copy((void*)eaddr, (void*)saddr, plen);
					}
					eaddr += plen; // Move processed storage pointer ahead
				}
				else infob1("discard %s", value, length, name);
				saddr += plen;
			}
			else {
				saddr++;
			}
		}
		return eaddr;
	}

	error_t initStorage() {
		error_t result;
		nvparams_storage_header_t hdr;
		// The header is duplicated, to recover when a header write fails
		// It is safe to run the upgrade procedure multiple times, storage area
		// can only shrink with upgrade - default values are not stored
		debug2("nvp %u %p+%u (%p>%p)", total_parameters,
		       (void*)storage_area_start, storage_data_length + 2*sizeof(nvparams_storage_header_t),
		       (void*)NVPARAMS_DATA_START, (void*)NVPARAMS_DATA_END);

		result = loadHeader(&hdr, storage_area_start); // Load header A
		if(result == SUCCESS) {
			nvparams_storage_header_t bhdr;
			error_t bresult = loadHeader(&bhdr, storage_area_start + sizeof(hdr)); // Load header B
			if((bresult != SUCCESS) || (memcmp(&hdr, &bhdr, sizeof(hdr)) != 0)) { // Overwrite header B if it does not match
				call InternalFlash.write((void*)(storage_area_start + sizeof(hdr)), &hdr, sizeof(hdr));
			}
		}
		else {
			result = loadHeader(&hdr, storage_area_start + sizeof(hdr));
			if(result == SUCCESS) {
				call InternalFlash.write((void*)storage_area_start, &hdr, sizeof(hdr)); // Rewrite header A
			}
			else {
				if(m_state == ST_BADBOOT) { // Do not touch the flash if badboot and no headers found - fear MCU issues
					return FAIL;
				}
			}
		}

		if(result == SUCCESS) {
			uint16_t data_end = loadAllValues(NVPARAMS_DATA_START, hdr.length);
			#ifndef NVPARAMS_STORAGE_NO_MIGRATION
				if(hdr.uidhash != IDENT_UIDHASH) {
					info1("migrate %"PRIX32"->%"PRIX32, (uint32_t)hdr.uidhash, (uint32_t)IDENT_UIDHASH);
					if(storage_data_length < hdr.length) {
						internalFlash_erase((void*)(NVPARAMS_DATA_START+storage_data_length), storage_data_length-hdr.length);
					}
					debug1("%"PRIu32" %"PRIu32" %"PRIu32, (uint32_t)storage_data_length, (uint32_t)data_end, (uint32_t)NVPARAMS_DATA_START);
					if(data_end - NVPARAMS_DATA_START < storage_data_length) {
						internalFlash_erase((void*)data_end, storage_data_length - (data_end - NVPARAMS_DATA_START));
					}
					hdr.uidhash = IDENT_UIDHASH;
					hdr.length = storage_data_length;
					hdr.crc = call Crc.crc16(&hdr, sizeof(hdr)-2);
					debug1("A");
					call InternalFlash.write((void*)(storage_area_start), &hdr, sizeof(hdr));
					debug1("B");
					call InternalFlash.write((void*)(storage_area_start + sizeof(hdr)), &hdr, sizeof(hdr));
					debug1("ok");
				}
			#else
				debug1("ldd %d", data_end);
			#endif//NVPARAMS_STORAGE_NO_MIGRATION
		}
		else {
			strncpy_P(hdr.storage_key, storage_header_key, strlen_P(storage_header_key));
			hdr.uidhash = IDENT_UIDHASH;
			hdr.length = storage_data_length;
			hdr.crc = call Crc.crc16(&hdr, sizeof(hdr)-2);
			call InternalFlash.write((void*)(storage_area_start), &hdr, sizeof(hdr));
			call InternalFlash.write((void*)(storage_area_start + sizeof(hdr)), &hdr, sizeof(hdr));
			internalFlash_erase((void*)(NVPARAMS_DATA_START), storage_data_length);
		}

		debug2("rdy %d", result);
		return SUCCESS;
	}

	event void SysBoot.booted() {
		if(m_state == ST_OFF) {
			if(initStorage() == SUCCESS) {
				m_state = ST_ACTIVE;
			}
			signal Boot.booted();
		}
	}

	event void BadBoot.booted() {
		if(m_state == ST_OFF) {
			m_state = ST_BADBOOT;
			if(initStorage() == SUCCESS) {
				m_state = ST_ACTIVE;
			}
			signal Boot.booted();
		}
	}

	command error_t NvParameter.store[uint8_t param](const char* identifier, void* pvalue, uint8_t vlen) {
		if(m_state == ST_ACTIVE) {
			if(param < total_parameters) {
				uint16_t saddr = NVPARAMS_DATA_START;
				while(saddr < NVPARAMS_DATA_END - NVPARAMS_MIN_ELEMENT_SIZE) {
					char name[16+1];
					uint8_t plen = loadParameter((void*)saddr, name, NULL, NULL);
					if(plen > 0) { // Loaded something useful
						if(strcmp(name, identifier) == 0) { // Replace existing entry
							return storeParameter((void*)saddr, identifier, pvalue, vlen);
						}
						saddr += plen;
					}
					else { // End reached
						return storeParameter((void*)saddr, identifier, pvalue, vlen);
					}
				}
				err1("%u end %p", param, (void*)saddr);
				return ESIZE;
			}
			else err1("%u param", param);
			return EINVAL;
		}
		else err1("%u state %u", param, m_state);
		return EOFF;
	}

	default event bool NvParameter.matches[uint8_t param](const char* identifier) { return FALSE; }
	default event error_t NvParameter.init[uint8_t param](void* pvalue, uint8_t vlen) { return EINVAL; }

}
