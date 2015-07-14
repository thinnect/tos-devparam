/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
generic module LowPowerListeningParametersP() {
	provides {
		interface DeviceParameter as RemoteWakeup;
		interface DeviceParameter as LocalWakeup;
		interface DeviceParameter as Delay;
	}
	uses {
		interface LowPowerListening;
		interface SystemLowPowerListening;
	}
}
implementation {

	PROGMEM const char m_remote_wakeup_id[] = "lpl_remote_wakeup";
	PROGMEM const char m_local_wakeup_id[]  = "lpl_local_wakeup";
	PROGMEM const char m_delay_id[]         = "lpl_delay";

	task void remote() {
		char id[sizeof(m_remote_wakeup_id)];
		nx_uint16_t remote_wakeup;
		remote_wakeup = call SystemLowPowerListening.getDefaultRemoteWakeupInterval();
		strcpy_P(id, m_remote_wakeup_id);
		signal RemoteWakeup.value(id, DP_TYPE_UINT16, &remote_wakeup, sizeof(remote_wakeup));
	}

	task void local() {
		char id[sizeof(m_local_wakeup_id)];
		nx_uint16_t local_wakeup;
		local_wakeup = call LowPowerListening.getLocalWakeupInterval();
		strcpy_P(id, m_local_wakeup_id);
		signal LocalWakeup.value(id, DP_TYPE_UINT16, &local_wakeup, sizeof(local_wakeup));
	}

	task void delay() {
		char id[sizeof(m_delay_id)];
		nx_uint16_t delay_after_receive;
		delay_after_receive = call SystemLowPowerListening.getDelayAfterReceive();
		strcpy_P(id, m_delay_id);
		signal Delay.value(id, DP_TYPE_UINT16, &delay_after_receive, sizeof(delay_after_receive));
	}

	command error_t RemoteWakeup.set(void* value, uint8_t length) {
		if(length == sizeof(nx_uint16_t)) {
			call SystemLowPowerListening.setDefaultRemoteWakeupInterval(*((nx_uint16_t*)value));
			post remote();
			return SUCCESS;
		}
		return FAIL;
	}

	command error_t LocalWakeup.set(void* value, uint8_t length) {
		if(length == sizeof(nx_uint16_t)) {
			call LowPowerListening.setLocalWakeupInterval(*((nx_uint16_t*)value));
			post local();
			return SUCCESS;
		}
		return FAIL;
	}

	command error_t Delay.set(void* value, uint8_t length) {
		if(length == sizeof(nx_uint16_t)) {
			call SystemLowPowerListening.setDelayAfterReceive(*((nx_uint16_t*)value));
			post delay();
			return SUCCESS;
		}
		return FAIL;
	}

	command error_t RemoteWakeup.get() { return post remote(); }
	command error_t LocalWakeup.get()  { return post local(); }
	command error_t Delay.get()        { return post delay(); }

	command bool RemoteWakeup.matches(const char* identifier) { return 0 == strcmp_P(identifier, m_remote_wakeup_id); }
	command bool LocalWakeup.matches(const char* identifier)  { return 0 == strcmp_P(identifier, m_local_wakeup_id); }
	command bool Delay.matches(const char* identifier)        { return 0 == strcmp_P(identifier, m_delay_id); }

}
