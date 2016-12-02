/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "sec_tmilli.h"
#include "DeviceParameters.h"
generic module DeviceParametersP(uint16_t g_period_s, uint8_t g_parameters) {
	provides {
		interface SerialPacketInfo;
	}
	uses {
		interface Send[uint8_t iface];
		interface Receive[uint8_t iface];
		interface Timer<TMilli>;
		interface LocalTime<TSecond> as LocalTimeSecond;
		interface LocalIeeeEui64;
		interface DeviceParameter[uint8_t seqnum];
		interface Boot @exactlyonce();
	}
}
implementation {

	#define __MODUUL__ "DevP"
	#define __LOG_LEVEL__ ( LOG_LEVEL_DeviceParametersP & BASE_LOG_LEVEL )
	#include "log.h"

	bool m_busy = FALSE;
	uint8_t m_interface = 0; // The interface where the message came from, heartbeat is only sent on interface 0
	message_t m_msg;

	event void Boot.booted() {
		if(g_period_s > 0) { // Heartbeat is disabled when set to 0
			call Timer.startPeriodic(SEC_TMILLI(g_period_s));
		}
	}

	void errorSeqnum(uint8_t iface, bool exists, error_t error, uint8_t seqnum) {
		if(!m_busy) {
			dp_error_parameter_seqnum_t* ep = (dp_error_parameter_seqnum_t*) call Send.getPayload[iface](&m_msg, sizeof(dp_error_parameter_seqnum_t));
			if(ep != NULL) {
				error_t err;
				ep->header = DP_ERROR_PARAMETER_SEQNUM;
				ep->exists = exists;
				ep->error = error;
				ep->seqnum = seqnum;

				err = call Send.send[iface](&m_msg, sizeof(dp_error_parameter_seqnum_t));
				logger(err == SUCCESS ? LOG_DEBUG1: LOG_WARN1, "esnd %u", err);
				if(err == SUCCESS) {
					m_busy = TRUE;
				}
			}
		}
		else warn1("bsy");
	}

	void errorId(uint8_t iface, bool exists, error_t error, uint8_t idstr[], uint8_t idlen) {
		if(!m_busy) {
			dp_error_parameter_id_t* ep = (dp_error_parameter_id_t*) call Send.getPayload[iface](&m_msg, sizeof(dp_error_parameter_id_t));
			if(ep != NULL) {
				error_t err;
				ep->header = DP_ERROR_PARAMETER_ID;
				ep->exists = exists;
				ep->error = error;
				ep->idlength = idlen;
				memcpy((uint8_t*)ep + sizeof(dp_error_parameter_id_t), idstr, idlen);

				err = call Send.send[iface](&m_msg, sizeof(dp_error_parameter_id_t) + ep->idlength);
				logger(err == SUCCESS ? LOG_DEBUG1: LOG_WARN1, "esnd %u", err);
				if(err == SUCCESS) {
					m_busy = TRUE;
				}
			}
		}
		else warn1("bsy");
	}

	event void Timer.fired() {
		if(!m_busy) {
			dp_heartbeat_t* hb = (dp_heartbeat_t*) call Send.getPayload[0](&m_msg, sizeof(dp_heartbeat_t));
			if(hb != NULL) {
				error_t err;
				uint32_t uptime = call LocalTimeSecond.get();
				ieee_eui64_t eui64 = call LocalIeeeEui64.getId();

				hb->header = DP_HEARTBEAT;
				memcpy(hb->eui64, eui64.data, sizeof(hb->eui64));
				hb->uptime = uptime;

				err = call Send.send[0](&m_msg, sizeof(dp_heartbeat_t));
				logger(err == SUCCESS ? LOG_DEBUG1: LOG_WARN1, "hsnd %"PRIu32" (%u)", uptime, err);
				if(err == SUCCESS) {
					m_busy = TRUE;
				}
			}
		}
		else warn1("bsy");
	}

	event void Send.sendDone[uint8_t iface](message_t* msg, error_t error) {
		m_busy = FALSE;
	}

	event void DeviceParameter.value[uint8_t seqnum](const char* fid, uint8_t type, void* value, uint8_t length) {
		debugb3("dp.v[%u] %s", value, length, seqnum, fid);
		if(!m_busy) {
			uint8_t idlen = strlen(fid);
			dp_parameter_t* df = (dp_parameter_t*) call Send.getPayload[m_interface](&m_msg, sizeof(dp_parameter_t) + idlen + length);
			if(df != NULL) {
				error_t err;

				df->header = DP_PARAMETER;
				df->type = type;
				df->seqnum = seqnum;
				df->idlength = idlen;
				df->valuelength = length;
				memcpy(((uint8_t*)df)+sizeof(dp_parameter_t), fid, idlen);
				memcpy(((uint8_t*)df)+sizeof(dp_parameter_t)+idlen, value, length);

				err = call Send.send[m_interface](&m_msg, sizeof(dp_parameter_t) + idlen + length);
				logger(err == SUCCESS ? LOG_DEBUG1: LOG_WARN1, "vsnd [%02X]%s (%u)", seqnum, fid, err);
				if(err == SUCCESS) {
					m_busy = TRUE;
				}
			}
		}
	}

	uint8_t getSeqNum(uint8_t* idstr, uint8_t idlen) {
		char fid[idlen+1];
		uint8_t i;

		memcpy(fid, idstr, idlen);
		fid[idlen] = '\0';

		for(i=0;i<g_parameters;i++) {
			if(call DeviceParameter.matches[i](fid)) {
				return i;
			}
		}
		return g_parameters;
	}

	event message_t* Receive.receive[uint8_t iface](message_t* msg, void* payload, uint8_t len) {
		debugb1("rcv[%u]", payload, len, iface);
		if(len > 0) {
			switch(((uint8_t*)payload)[0]) {
				case DP_HEARTBEAT:
					// something?
					// Maybe make the info about last heartbeat available for other apps?
					break;
				case DP_GET_PARAMETER_WITH_ID:
					if(len >= sizeof(dp_get_parameter_id_t)) {
						dp_get_parameter_id_t* gf = (dp_get_parameter_id_t*)payload;
						uint8_t seqnum = getSeqNum(((uint8_t*)payload) + sizeof(dp_get_parameter_id_t), gf->idlength);
						if(seqnum < g_parameters) {
							error_t err = call DeviceParameter.get[seqnum]();
							if(err == SUCCESS) {
								m_interface = iface;
							}
							else warn1("g %u", seqnum);
						}
						else { // No such parameter found
							errorId(iface, FALSE, EINVAL, ((uint8_t*)payload) + sizeof(dp_get_parameter_id_t), gf->idlength);
						}
					}
					break;
				case DP_GET_PARAMETER_WITH_SEQNUM:
					if(len >= sizeof(dp_get_parameter_seqnum_t)) {
						dp_get_parameter_seqnum_t* gf = (dp_get_parameter_seqnum_t*)payload;
						if(gf->seqnum < g_parameters) {
							error_t err = call DeviceParameter.get[gf->seqnum]();
							if(err == SUCCESS) {
								m_interface = iface;
							}
							else warn1("g %u", gf->seqnum);
						}
						else { // No such parameter
							errorSeqnum(iface, FALSE, EINVAL, gf->seqnum);
						}
					}
					break;
				case DP_SET_PARAMETER_WITH_ID:
					if(len >= sizeof(dp_set_parameter_id_t)) {
						dp_set_parameter_id_t* sf = (dp_set_parameter_id_t*)payload;
						if(len == sizeof(dp_set_parameter_id_t) + sf->idlength + sf->valuelength) {
							uint8_t seqnum = getSeqNum(((uint8_t*)payload) + sizeof(dp_set_parameter_id_t), sf->idlength);
							if(seqnum < g_parameters) {
								uint8_t* value = ((uint8_t*)payload) + sizeof(dp_set_parameter_id_t) + sf->idlength;
								error_t err = call DeviceParameter.set[seqnum](value, sf->valuelength);
								if(err == SUCCESS) {
									m_interface = iface;
								}
								else {
									warnb1("s %u", value, sf->valuelength, seqnum);
									errorId(iface, TRUE, err, ((uint8_t*)payload) + sizeof(dp_set_parameter_id_t), sf->idlength);
								}
							}
							else {// No such parameter found
								errorId(iface, FALSE, EINVAL, ((uint8_t*)payload) + sizeof(dp_set_parameter_id_t), sf->idlength);
							}
						}
						else warnb1("len", payload, len);
					}
					break;
				case DP_SET_PARAMETER_WITH_SEQNUM:
					if(len >= sizeof(dp_set_parameter_seqnum_t)) {
						dp_set_parameter_seqnum_t* sf = (dp_set_parameter_seqnum_t*)payload;
						if(sf->seqnum < g_parameters) {
							uint8_t* value = ((uint8_t*)payload) + sizeof(dp_set_parameter_seqnum_t);
							error_t err = call DeviceParameter.set[sf->seqnum](value, sf->valuelength);
							if(err == SUCCESS) {
								m_interface = iface;
							}
							else {
								warnb1("s %u", value, sf->valuelength, sf->seqnum);
								errorSeqnum(iface, TRUE, err, sf->seqnum);
							}
						}
						else { // No such parameter
							errorSeqnum(iface, FALSE, EINVAL, sf->seqnum);
						}
					}
					break;
				default:
					warnb1("dflt", payload, len);
					break;
			}
		}
		return msg;
	}

	async command uint8_t SerialPacketInfo.offset() { return 0; }
	async command uint8_t SerialPacketInfo.dataLinkLength(message_t* msg, uint8_t upperLen) { return upperLen; }
	async command uint8_t SerialPacketInfo.upperLength(message_t* msg, uint8_t dataLinkLen) { return dataLinkLen; }

	default command bool DeviceParameter.matches[uint8_t seqnum](const char* id) { return FALSE; }
	default command error_t DeviceParameter.get[uint8_t seqnum]() { return EINVAL; }
	default command error_t DeviceParameter.set[uint8_t seqnum](void* data, uint8_t length) { return EINVAL; }

	default command error_t Send.send[uint8_t iface](message_t* msg, uint8_t len) { return EINVAL; }
	default command void* Send.getPayload[uint8_t iface](message_t* msg, uint8_t len) { return NULL; }

}
