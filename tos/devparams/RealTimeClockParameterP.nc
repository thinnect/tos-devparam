/**
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
generic module RealTimeClockParameterP() {
	provides {
		interface DeviceParameter;
	}
	uses {
		interface RealTimeClock;
		interface LocalTime<TSecond> as LocalTimeSecond;
		interface Set<uint32_t> as SetNetworkTimeOffset;
	}
}
implementation {

	PROGMEM const char m_parameter_id[] = "unix_time";

	task void getTask() {
		char id[sizeof(m_parameter_id)];
		nx_time64_t rtc;
		rtc = call RealTimeClock.time();
		strcpy_P(id, m_parameter_id);
		signal DeviceParameter.value(id, DP_TYPE_INT64, &rtc, sizeof(rtc));
	}

	task void updatedTask() {
		time64_t rtc = call RealTimeClock.time();
		uint32_t yxko = 0;
		if(rtc != (time64_t)(-1)) {
			yxko = yxktime(&rtc) - call LocalTimeSecond.get();
		}
		call SetNetworkTimeOffset.set(yxko);
	}

	command error_t DeviceParameter.set(void* value, uint8_t length) {
		if(length == sizeof(nx_time64_t)) {
			error_t err;
			time64_t rtc;
			rtc = (time64_t)*((nx_time64_t*)value);
			err = call RealTimeClock.stime(rtc);
			if(err == SUCCESS) {
				post updatedTask();
				post getTask();
			}
			return err;
		}
		return EINVAL;
	}

	async event void RealTimeClock.changed(time64_t old, time64_t current) { }

	command error_t DeviceParameter.get() { return post getTask(); }

	command bool DeviceParameter.matches(const char* identifier) { return 0 == strcmp_P(identifier, m_parameter_id); }

	default command void SetNetworkTimeOffset.set(uint32_t value) { /* Network time offset setting is optional */ }

}
