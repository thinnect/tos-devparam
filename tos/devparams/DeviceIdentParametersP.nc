/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
#include "SemanticVersion.h"
generic module DeviceIdentParametersP() {
	provides {
		interface DeviceParameter as Eui64;
		interface DeviceParameter as Boardname;
		interface DeviceParameter as Appname;
		interface DeviceParameter as Uidhash;
		interface DeviceParameter as Timestamp;
		interface DeviceParameter as SwVersion;
		interface DeviceParameter as PcbVersion;
	}
	uses {
		interface LocalIeeeEui64;
		interface Get<semantic_version_t> as GetPCBVersion;
	}
}
implementation {

	PROGMEM const char m_eui_id[] = "eui64";
	PROGMEM const char m_boardname_id[] = "ident_boardname";
	PROGMEM const char m_appname_id[] = "ident_appname";
	PROGMEM const char m_uidhash_id[] = "ident_uidhash";
	PROGMEM const char m_timestamp_id[] = "ident_timestamp";
	PROGMEM const char m_swversion_id[] = "sw_version";
	PROGMEM const char m_pcbversion_id[] = "pcb_version";

	task void eui() {
		char id[sizeof(m_eui_id)];
		ieee_eui64_t eui64 = call LocalIeeeEui64.getId();
		strcpy_P(id, m_eui_id);
		signal Eui64.value(id, DP_TYPE_RAW, &eui64, sizeof(eui64));
	}

	task void boardname() {
		char id[sizeof(m_boardname_id)];
		char bn[strlen(IDENT_BOARDNAME)];
		strcpy_P(id, m_boardname_id);
		memcpy(bn, IDENT_BOARDNAME, strlen(IDENT_BOARDNAME));
		signal Boardname.value(id, DP_TYPE_STRING, &bn, sizeof(bn));
	}

	task void appname() {
		char id[sizeof(m_appname_id)];
		char an[strlen(IDENT_APPNAME)];
		strcpy_P(id, m_appname_id);
		memcpy(an, IDENT_APPNAME, strlen(IDENT_APPNAME));
		signal Appname.value(id, DP_TYPE_STRING, &an, sizeof(an));
	}

	task void uidhash() {
		char id[sizeof(m_uidhash_id)];
		nx_uint32_t uh;
		uh = IDENT_UIDHASH;
		strcpy_P(id, m_uidhash_id);
		signal Uidhash.value(id, DP_TYPE_RAW, &uh, sizeof(uh));
	}

	task void timestamp() {
		char id[sizeof(m_timestamp_id)];
		nx_uint32_t ts;
		ts = IDENT_TIMESTAMP;
		strcpy_P(id, m_timestamp_id);
		signal Timestamp.value(id, DP_TYPE_RAW, &ts, sizeof(ts));
	}

	task void swversion() {
		char id[sizeof(m_swversion_id)];
		uint8_t v[3];
		strcpy_P(id, m_swversion_id);
		v[0] = SW_MAJOR_VERSION;
		v[1] = SW_MINOR_VERSION;
		v[2] = SW_PATCH_VERSION;
		signal SwVersion.value(id, DP_TYPE_RAW, &v, sizeof(v));
	}

	task void pcbversion() {
		char id[sizeof(m_pcbversion_id)];
		semantic_version_t pcbv = call GetPCBVersion.get();
		uint8_t v[3];
		strcpy_P(id, m_pcbversion_id);
		v[0] = pcbv.major;
		v[1] = pcbv.minor;
		v[2] = pcbv.patch;
		signal PcbVersion.value(id, DP_TYPE_RAW, &v, sizeof(v));
	}

	command error_t Eui64.set(void* payload, uint8_t length)      { return FAIL; }
	command error_t Boardname.set(void* payload, uint8_t length)  { return FAIL; }
	command error_t Appname.set(void* payload, uint8_t length)    { return FAIL; }
	command error_t Uidhash.set(void* payload, uint8_t length)    { return FAIL; }
	command error_t Timestamp.set(void* payload, uint8_t length)  { return FAIL; }
	command error_t SwVersion.set(void* payload, uint8_t length)  { return FAIL; }
	command error_t PcbVersion.set(void* payload, uint8_t length) { return FAIL; }

	command error_t Eui64.get()      { return post eui(); }
	command error_t Boardname.get()  { return post boardname(); }
	command error_t Appname.get()    { return post appname(); }
	command error_t Uidhash.get()    { return post uidhash(); }
	command error_t Timestamp.get()  { return post timestamp(); }
	command error_t SwVersion.get()  { return post swversion(); }
	command error_t PcbVersion.get() { return post pcbversion(); }

	command bool Eui64.matches(const char* identifier)      { return 0 == strcmp_P(identifier, m_eui_id); }
	command bool Boardname.matches(const char* identifier)  { return 0 == strcmp_P(identifier, m_boardname_id); }
	command bool Appname.matches(const char* identifier)    { return 0 == strcmp_P(identifier, m_appname_id); }
	command bool Uidhash.matches(const char* identifier)    { return 0 == strcmp_P(identifier, m_uidhash_id); }
	command bool Timestamp.matches(const char* identifier)  { return 0 == strcmp_P(identifier, m_timestamp_id); }
	command bool SwVersion.matches(const char* identifier)  { return 0 == strcmp_P(identifier, m_swversion_id); }
	command bool PcbVersion.matches(const char* identifier) { return 0 == strcmp_P(identifier, m_pcbversion_id); }

}
