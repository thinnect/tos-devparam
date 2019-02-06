/**
 * @author Raido Pahtma
 * @license MIT
 **/
#ifndef DEVICEPARAMETERS_H_
#define DEVICEPARAMETERS_H_

	#include "IeeeEui64.h"

 	#define UQ_DEVICE_PARAMETER_SEQNUM unique("DeviceParameter")
	#define UQ_DEVICE_PARAMETER_INTERFACE_ID unique("DeviceParametersCommunicationsInterface")

	enum DeviceParametersHeartbeatInterfaceEnum {
		DP_HEARTBEAT_INTERFACE_ID = UQ_DEVICE_PARAMETER_INTERFACE_ID
	};

	#ifndef TOS_SERIAL_DEVICE_PARAMETERS_ID
 	#define TOS_SERIAL_DEVICE_PARAMETERS_ID 0x80
 	#endif // TOS_SERIAL_DEVICE_PARAMETERS_ID

	#ifndef AMID_DEVICE_PARAMETERS
	#define AMID_DEVICE_PARAMETERS 0x82
	#endif // AMID_DEVICE_PARAMETERS

 	#ifndef DP_HEARTBEAT_PERIOD_S
 	#define DP_HEARTBEAT_PERIOD_S 0
 	#endif // DP_HEARTBEAT_PERIOD_S

	enum DeviceParametersHeader {
		DP_HEARTBEAT = 0x00,

		DP_PARAMETER = 0x10,

		DP_GET_PARAMETER_WITH_ID     = 0x21,
		DP_GET_PARAMETER_WITH_SEQNUM = 0x22,

		DP_SET_PARAMETER_WITH_ID     = 0x31,
		DP_SET_PARAMETER_WITH_SEQNUM = 0x32,

		DP_ERROR_PARAMETER_ID     = 0xF0,
		DP_ERROR_PARAMETER_SEQNUM = 0xF1
	};

	enum DeviceParameterTypes {
		DP_TYPE_RAW     = 0x00, // 00000000

		DP_TYPE_UINT8   = 0x01, // 00000001
		DP_TYPE_UINT16  = 0x02, // 00000010
		DP_TYPE_UINT32  = 0x04, // 00000100
		DP_TYPE_UINT64  = 0x08, // 00001000

		DP_ARRAY_UINT8  = 0x11, // 00010001
		DP_ARRAY_UINT16 = 0x12, // 00010010
		DP_ARRAY_UINT32 = 0x14, // 00010100
		DP_ARRAY_UINT64 = 0x18, // 00011000

		DP_TYPE_STRING  = 0x80, // 10000000

		DP_TYPE_INT8    = 0x81, // 10000001
		DP_TYPE_INT16   = 0x82, // 10000010
		DP_TYPE_INT32   = 0x84, // 10000100
		DP_TYPE_INT64   = 0x88, // 10001000

		DP_ARRAY_INT8   = 0x91, // 10010001
		DP_ARRAY_INT16  = 0x92, // 10010010
		DP_ARRAY_INT32  = 0x94, // 10010100
		DP_ARRAY_INT64  = 0x98, // 10011000

		DP_TYPE_BOOL    = 0xFF, // 11111111
	};

	typedef struct dp_heartbeat_t {
		nx_uint8_t header;
		nx_uint8_t eui64[IEEE_EUI64_LENGTH]; // device EUI64
		nx_uint32_t uptime; // seconds
	} dp_heartbeat_t;

	typedef nx_struct dp_parameter_t {
		nx_uint8_t header; // DP_FEATURE
		nx_uint8_t type;
		nx_uint8_t seqnum;
		nx_uint8_t idlength;
		nx_uint8_t valuelength;
		//nx_uint8_t id[];
		//nx_uint8_t value[];
	} dp_parameter_t;

	typedef nx_struct dp_get_parameter_seqnum_t {
		nx_uint8_t header;
		nx_uint8_t seqnum;
	} dp_get_parameter_seqnum_t;

	typedef nx_struct dp_get_parameter_id_t {
		nx_uint8_t header;
		nx_uint8_t idlength;
		//nx_uint8_t id[];
	} dp_get_parameter_id_t;

	typedef nx_struct dp_set_parameter_seqnum_t {
		nx_uint8_t header;
		nx_uint8_t seqnum;
		nx_uint8_t valuelength;
		//nx_uint8_t value[];
	} dp_set_parameter_seqnum_t;

	typedef nx_struct dp_set_parameter_id_t {
		nx_uint8_t header;
		nx_uint8_t idlength;
		nx_uint8_t valuelength;
		//nx_uint8_t id[];
		//nx_uint8_t value[];
	} dp_set_parameter_id_t;

	typedef nx_struct dp_error_parameter_seqnum_t {
		nx_uint8_t header;
		nx_uint8_t exists;
		nx_uint8_t error;
		nx_uint8_t seqnum;
	} dp_error_parameter_seqnum_t;

	typedef nx_struct dp_error_parameter_id_t {
		nx_uint8_t header;
		nx_uint8_t exists;
		nx_uint8_t error;
		nx_uint8_t idlength;
		//nx_uint8_t id[];
	} dp_error_parameter_id_t;

#ifdef TOSSIM
	#ifndef PROGMEM
	#define PROGMEM
	#endif// PROGMEM
	size_t strlcpy_P(char* dst, const char* src, size_t dstsize) {
		return strlcpy(dst, src, dstsize);
	}
	char* strcpy_P(char* destination, const char* source) {
		return strcpy(destination, source);
	}
	int strcmp_P(const char* str1, const char* str2) {
		return strcmp(str1, str2);
	}
#endif//TOSSIM

#endif // DEVICEPARAMETERS_H_
