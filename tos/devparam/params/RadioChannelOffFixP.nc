/**
 * @author Raido Pahtma
 * @license MIT
 **/
module RadioChannelOffFixP {
	provides {
		interface RadioChannel;
	}
	uses {
		interface RadioChannel as RealRadioChannel;
		interface SplitControl as RadioControl;
	}
}
implementation {

	#warning "RadioChannelOffFix - radio must be on to change the channel"

	bool m_radio_on = FALSE;

	event void RadioControl.startDone(error_t err) {
		if(err == SUCCESS) {
			m_radio_on = TRUE;
		}
	}

	event void RadioControl.stopDone(error_t result) {
		if(result == SUCCESS) {
			m_radio_on = FALSE;
		}
	}

	command uint8_t RadioChannel.getChannel() {
		return call RealRadioChannel.getChannel();
	}

	command error_t RadioChannel.setChannel(uint8_t channel) {
		if(m_radio_on) {
			return call RealRadioChannel.setChannel(channel);
		}
		return EOFF;
	}

	event void RealRadioChannel.setChannelDone() {
		signal RadioChannel.setChannelDone();
	}

}
