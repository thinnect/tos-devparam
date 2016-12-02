/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
#include <avr/boot.h>
generic module AtmegaFuseParameterP() {
	provides {
		interface DeviceParameter as HighFuse;
		interface DeviceParameter as LowFuse;
		interface DeviceParameter as ExtendedFuse;
		interface DeviceParameter as LockFuse;
	}
}
implementation {

	PROGMEM const char m_lfuse_id[] = "lfuse";
	PROGMEM const char m_hfuse_id[] = "hfuse";
	PROGMEM const char m_efuse_id[] = "efuse";
	PROGMEM const char m_lock_id[] = "lock";

	task void hfuse() {
		char id[sizeof(m_hfuse_id)];
		uint8_t fuse = boot_lock_fuse_bits_get(GET_HIGH_FUSE_BITS);
		strcpy_P(id, m_hfuse_id);
		signal HighFuse.value(id, DP_TYPE_RAW, &fuse, sizeof(fuse));
	}

	task void lfuse() {
		char id[sizeof(m_lfuse_id)];
		uint8_t fuse = boot_lock_fuse_bits_get(GET_LOW_FUSE_BITS);
		strcpy_P(id, m_lfuse_id);
		signal LowFuse.value(id, DP_TYPE_RAW, &fuse, sizeof(fuse));
	}

	task void efuse() {
		char id[sizeof(m_efuse_id)];
		uint8_t fuse = boot_lock_fuse_bits_get(GET_EXTENDED_FUSE_BITS);
		strcpy_P(id, m_efuse_id);
		signal ExtendedFuse.value(id, DP_TYPE_RAW, &fuse, sizeof(fuse));
	}

	task void lockfuse() {
		char id[sizeof(m_lock_id)];
		uint8_t fuse = boot_lock_fuse_bits_get(GET_LOCK_BITS);
		strcpy_P(id, m_lock_id);
		signal LockFuse.value(id, DP_TYPE_RAW, &fuse, sizeof(fuse));
	}

	command error_t HighFuse.set(void* payload, uint8_t length)     { return FAIL; }
	command error_t LowFuse.set(void* payload, uint8_t length)      { return FAIL; }
	command error_t ExtendedFuse.set(void* payload, uint8_t length) { return FAIL; }
	command error_t LockFuse.set(void* payload, uint8_t length)     { return FAIL; }

	command error_t HighFuse.get()     { return post hfuse(); }
	command error_t LowFuse.get()      { return post lfuse(); }
	command error_t ExtendedFuse.get() { return post efuse(); }
	command error_t LockFuse.get()     { return post lockfuse(); }

	command bool HighFuse.matches(const char* identifier)     { return 0 == strcmp_P(identifier, m_hfuse_id); }
	command bool LowFuse.matches(const char* identifier)      { return 0 == strcmp_P(identifier, m_lfuse_id); }
	command bool ExtendedFuse.matches(const char* identifier) { return 0 == strcmp_P(identifier, m_efuse_id); }
	command bool LockFuse.matches(const char* identifier)     { return 0 == strcmp_P(identifier, m_lock_id); }

}
