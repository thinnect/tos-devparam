/**
 * DeviceParameters handler for ActiveMessage and TOS_NODE_ID parameters.
 *
 * Does not allow the use of 0xFFFF for address and 0 for group.
 *
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
#include "ActiveMessageParameters.h"
generic module ActiveMessageParametersP() {
	provides {
		interface Boot;
		interface DeviceParameter[uint8_t param];
	}
	uses {
		interface Boot as SysBoot  @exactlyonce();
		interface ActiveMessageAddress;
		interface NvParameter[uint8_t param];
	}
}
implementation {

	#define __MODUUL__ "amp"
	#define __LOG_LEVEL__ ( LOG_LEVEL_ActiveMessageParametersP & BASE_LOG_LEVEL )
	#include "log.h"

	PROGMEM const char m_node_id[]  = "tos_node_id";
	PROGMEM const char m_addr_id[]  = "am_addr";
	PROGMEM const char m_group_id[] = "am_group";

	uint16_t m_tos_node_id = 0xFFFF;
	am_addr_t m_am_addr = AM_BROADCAST_ADDR;
	am_group_t m_am_group = 0;

	uint8_t m_request = 0;

	event void SysBoot.booted() {
		if(m_tos_node_id == 0xFFFF) {
			m_tos_node_id = TOS_NODE_ID;
		}
		if(m_am_addr == AM_BROADCAST_ADDR) {
			m_am_addr = call ActiveMessageAddress.amAddress();
		}
		if(m_am_group == 0) {
			m_am_group = call ActiveMessageAddress.amGroup();
		}

		info1("AM {%02X}%04X TOS_NODE_ID %04X", m_am_group, m_am_addr, m_tos_node_id);

		TOS_NODE_ID = m_tos_node_id;
		call ActiveMessageAddress.setAddress(m_am_group, m_am_addr);

		signal Boot.booted();
	}

	async event void ActiveMessageAddress.changed() { }

	char* parameterIdCopy(char* dest, uint8_t pos) {
		switch(pos) {
			case DP_AMP_TOS_NODE_ID         : return strcpy_P(dest, m_node_id);
			case DP_AMP_AM_ADDR             : return strcpy_P(dest, m_addr_id);
			case DP_AMP_AM_GROUP            : return strcpy_P(dest, m_group_id);
			default:
				*dest = '\0';
		}
		return dest;
	}

	task void responseTask() {
		uint8_t param;
		for(param=0;param<DP_AMP_LAST;param++) {
			if(m_request & (1 << param)) {
				char id[16+1];
				parameterIdCopy(id, param);
				if(param == DP_AMP_TOS_NODE_ID) {
					nx_uint16_t value;
					value = (nx_uint16_t)m_tos_node_id;
					signal DeviceParameter.value[param](id, DP_TYPE_RAW, &value, sizeof(value));
				}
				else if(param == DP_AMP_AM_ADDR) {
					nx_am_addr_t value;
					value = (nx_am_addr_t)m_am_addr;
					signal DeviceParameter.value[param](id, DP_TYPE_RAW, &value, sizeof(value));
				}
				else if(param == DP_AMP_AM_GROUP) {
					nx_am_group_t value;
					value = (nx_am_group_t)m_am_group;
					signal DeviceParameter.value[param](id, DP_TYPE_RAW, &value, sizeof(value));
				}

				m_request &= ~(1 << param);
				if(m_request) {
					post responseTask();
				}
			}
		}
	}

	default event void DeviceParameter.value[uint8_t pos](const char* identifier, uint8_t type, void* data, uint8_t length) { }

	command error_t DeviceParameter.set[uint8_t param](void* value, uint8_t length) {
		if(param == DP_AMP_TOS_NODE_ID) {
			uint16_t v = (uint16_t)(*((nx_uint16_t*)value));
			if(v != m_tos_node_id) {
				char id[16+1];
				strcpy_P(id, m_node_id);
				if(call NvParameter.store[param](id, &v, sizeof(v)) == SUCCESS) {
					m_tos_node_id = v;
				}
				else {
					return ERETRY;
				}
			}
		}
		else if(param == DP_AMP_AM_ADDR) {
			am_addr_t v = (am_addr_t)(*((nx_am_addr_t*)value));
			if(v != m_am_addr) {
				char id[16+1];
				strcpy_P(id, m_addr_id);
				if(call NvParameter.store[param](id, &v, sizeof(v)) == SUCCESS) {
					m_am_addr = v;
				}
				else {
					return ERETRY;
				}
			}
		}
		else if(param == DP_AMP_AM_GROUP) {
			am_group_t v = (am_group_t)(*((nx_am_group_t*)value));
			if(v != m_am_group) {
				char id[16+1];
				strcpy_P(id, m_group_id);
				if(call NvParameter.store[param](id, &v, sizeof(v)) == SUCCESS) {
					m_am_group = v;
				}
				else {
					return ERETRY;
				}
			}
		}
		else {
			return EINVAL;
		}

		m_request |= 1 << param;
		post responseTask();
		return SUCCESS;
	}

	default command error_t NvParameter.store[uint8_t pos](const char* identifier, void* pvalue, uint8_t vlen) {
		return ELAST;
	}

	command error_t DeviceParameter.get[uint8_t param]() {
		m_request |= 1 << param;
		return post responseTask();
	}

	bool matches(uint8_t param, const char* identifier) {
		switch(param) {
			case DP_AMP_TOS_NODE_ID: return 0 == strcmp_P(identifier, m_node_id);
			case DP_AMP_AM_ADDR    : return 0 == strcmp_P(identifier, m_addr_id);
			case DP_AMP_AM_GROUP   : return 0 == strcmp_P(identifier, m_group_id);
		}
		return FALSE;
	}

	command bool DeviceParameter.matches[uint8_t param](const char* identifier) {
		return matches(param, identifier);
	}

	event bool NvParameter.matches[uint8_t param](const char* identifier) {
		return matches(param, identifier);
	}

	event error_t NvParameter.init[uint8_t param](void* value, uint8_t length) {
		switch(param) {
			case DP_AMP_TOS_NODE_ID:
				if(length == sizeof(uint16_t)) {
					m_tos_node_id = *((uint16_t*)value);
					return SUCCESS;
				}
				return ESIZE;
			case DP_AMP_AM_ADDR:
				if(length == sizeof(am_addr_t)) {
					m_am_addr = *((am_addr_t*)value);
					return SUCCESS;
				}
				return ESIZE;
			case DP_AMP_AM_GROUP:
				if(length == sizeof(am_group_t)) {
					m_am_group = *((am_group_t*)value);
					return SUCCESS;
				}
				return ESIZE;
		}
		return EINVAL;
	}

}
