/**
 * @author Raido Pahtma
 * @license MIT
 **/
#ifndef DEVICEPARAMETERS_H_
#define DEVICEPARAMETERS_H_

 	#define UQ_DEVICE_PARAMETER_SEQNUM unique("DeviceParameter")

	#ifndef TOS_SERIAL_DEVICE_PARAMETERS_ID
 	#define TOS_SERIAL_DEVICE_PARAMETERS_ID 0x80
 	#endif // TOS_SERIAL_DEVICE_PARAMETERS_ID

 	#ifndef DP_HEARTBEAT_PERIOD_S
 	#define DP_HEARTBEAT_PERIOD_S 30
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
		DP_TYPE_RAW    = 0x00,
		DP_TYPE_UINT8  = 0x01,
		DP_TYPE_UINT16 = 0x02,
		DP_TYPE_UINT32 = 0x04,
		DP_TYPE_UINT64 = 0x08,

		DP_TYPE_STRING = 0x80,
		DP_TYPE_INT8   = 0x81,
		DP_TYPE_INT16  = 0x82,
		DP_TYPE_INT32  = 0x84,
		DP_TYPE_INT64  = 0x88,
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

#endif // DEVICEPARAMETERS_H_
