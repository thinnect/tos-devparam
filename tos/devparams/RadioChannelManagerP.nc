/**
 * RadioChannel manager. Initially sets channel from non-volatile memory and
 * later allows both temporary and persistent changes to the radio channel.
 *
 * @author Raido Pahtma
 * @license MIT
 */
generic module RadioChannelManagerP(uint8_t default_radio_channel) {
	provides {
		interface SplitControl;
		interface RadioChannel;
		interface DeviceParameter as DefaultChannelParameter;
		interface DeviceParameter as CurrentChannelParameter;
	}
	uses {
		interface SplitControl as SubSplitControl;
		interface RadioChannel as SubRadioChannel;
		interface NvParameter as StoredRadioChannel;
	}
}
implementation {

	#define __MODUUL__ "rChM"
	#define __LOG_LEVEL__ ( LOG_LEVEL_RadioChannelManagerP & BASE_LOG_LEVEL )
	#include "log.h"

	PROGMEM const char m_default_id[] = "default_radio_ch";
    PROGMEM const char m_current_id[] = "current_radio_ch";

	enum RadioChannelManagerStates {
		ST_OFF,
		ST_STARTING,
		ST_RUNNING,
		ST_STOPPING
	};

	typedef struct radio_channel_manager_state {
		uint8_t default_channel;
		uint8_t current_channel;
		uint8_t state : 3;
		bool current_requested : 1;
		bool change_requested : 1;
	} radio_channel_manager_state_t;

	radio_channel_manager_state_t m = { default_radio_channel, default_radio_channel, ST_OFF, FALSE, FALSE };

	task void defaultChannelTask() {
		char id[sizeof(m_default_id)];
		uint8_t rc = m.default_channel;
		strcpy_P(id, m_default_id);
		signal DefaultChannelParameter.value(id, DP_TYPE_UINT8, &rc, sizeof(rc));
	}

	task void currentChannelTask() {
		char id[sizeof(m_current_id)];
		uint8_t rc = m.current_channel;
		strcpy_P(id, m_current_id);
		if(m.state == ST_RUNNING) {
			rc = call SubRadioChannel.getChannel();
		}
		signal CurrentChannelParameter.value(id, DP_TYPE_UINT8, &rc, sizeof(rc));
		m.current_requested = FALSE;
	}

	command error_t DefaultChannelParameter.set(void* value, uint8_t length) {
		if(length == sizeof(uint8_t)) {
			uint8_t channel = *((uint8_t*)value);
			if(channel == m.default_channel) {
				post defaultChannelTask();
				return SUCCESS;
			}
			else {
				error_t err;
				char id[sizeof(m_default_id)];
				strcpy_P(id, m_default_id);
				err = call StoredRadioChannel.store(id, value, sizeof(uint8_t));
				if(err == SUCCESS) {
					m.default_channel = channel;
					post defaultChannelTask();
				}
				return err;
			}
		}
		return EINVAL;
	}

	command error_t CurrentChannelParameter.set(void* value, uint8_t length) {
		if(length == sizeof(uint8_t)) {
			uint8_t channel = *((uint8_t*)value);
			if(m.state == ST_RUNNING) {
				error_t err = call SubRadioChannel.setChannel(channel);
				if(err == EALREADY) {
					post currentChannelTask();
					return SUCCESS;
				}
				else if(err == SUCCESS) {
					m.current_requested = TRUE;
				}
				return err;
			}
			else {
				m.current_channel = channel;
				post currentChannelTask();
				return SUCCESS;
			}
		}
		return EINVAL;
	}

	command error_t DefaultChannelParameter.get() { return post defaultChannelTask(); }
	command error_t CurrentChannelParameter.get() { return post currentChannelTask(); }

	command bool DefaultChannelParameter.matches(const char* identifier) { return 0 == strcmp_P(identifier, m_default_id); }
	command bool CurrentChannelParameter.matches(const char* identifier) { return 0 == strcmp_P(identifier, m_current_id); }

	event bool StoredRadioChannel.matches(const char* identifier) { return 0 == strcmp_P(identifier, m_default_id); }

	event error_t StoredRadioChannel.init(void* value, uint8_t length) {
		if(length == sizeof(uint8_t)) {
			m.default_channel = *((uint8_t*)value);
			m.current_channel = m.default_channel;
			return SUCCESS;
		}
		return ESIZE;
	}

	command error_t SplitControl.start() {
		error_t err = call SubSplitControl.start();
		if(err == SUCCESS) {
			m.state = ST_STARTING;
		}
		return err;
	}

	command error_t SplitControl.stop() {
		error_t err = call SubSplitControl.stop();
		if(err == SUCCESS) {
			m.state = ST_STOPPING;
		}
		return err;
	}

	void startDone() {
		info1("radio_channel=%u", call SubRadioChannel.getChannel());
		m.state = ST_RUNNING;
		signal SplitControl.startDone(SUCCESS);
	}

	event void SubSplitControl.startDone(error_t result) {
		if(result == SUCCESS) {
			result = call SubRadioChannel.setChannel(m.current_channel);
			if(result == EALREADY) {
				startDone();
				if(m.current_requested) {
					post currentChannelTask();
				}
			}
			else if(result != SUCCESS) {
				err1("start channel(%u) fail %u", m.current_channel, result);
				signal SplitControl.startDone(SUCCESS); // Bad, but no good way to recover either - could delay and try again
			}
		}
		else {
			signal SplitControl.startDone(result);
		}
	}

	event void SubSplitControl.stopDone(error_t result) {
		if(result == SUCCESS) {
			m.state = ST_OFF;
		}
		signal SplitControl.stopDone(result);
	}

	command uint8_t RadioChannel.getChannel() {
		if(m.state == ST_RUNNING) {
			return call SubRadioChannel.getChannel();
		}
		else {
			return m.current_channel;
		}
	}

	task void setChannelDone() {
		m.change_requested = FALSE;
		signal RadioChannel.setChannelDone();
	}

	command error_t RadioChannel.setChannel(uint8_t channel) {
		if(channel == m.current_channel) {
			return EALREADY;
		}
		else {
			if(m.state == ST_RUNNING) {
				error_t err = call SubRadioChannel.setChannel(channel);
				if(err == EALREADY) {
					m.current_channel = channel;
				}
				else if(err == SUCCESS) {
					m.change_requested = TRUE;
				}
				return err;
			}
			else {
				m.current_channel = channel;
				post setChannelDone();
				return SUCCESS;
			}
		}
	}

	event void SubRadioChannel.setChannelDone() {
		m.current_channel = call SubRadioChannel.getChannel();
		if(m.current_requested) {
			post currentChannelTask();
		}
		if(m.change_requested) {
			m.change_requested = FALSE;
			signal RadioChannel.setChannelDone();
		}
		if(m.state == ST_STARTING) {
			startDone();
		}
	}

	default event void RadioChannel.setChannelDone() { }

}
