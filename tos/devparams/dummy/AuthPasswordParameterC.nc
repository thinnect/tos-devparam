/**
 * Dummy auth password parameter.
 *
 * @author Raido Pahtma
 * @license MIT
 **/
#include "DeviceParameters.h"
module AuthPasswordParameterC {
	provides interface CheckAuth;
}
implementation {

	#warning "DUMMY AuthPasswordParameter"

	char m_auth[16] = { 'd', 'u', 'm', 'm', 'y' };

	command bool CheckAuth.good(uint8_t* auth, uint8_t length) {
		if(call CheckAuth.empty() == FALSE) {
			if(length == sizeof(m_auth)) {
				return memcmp(auth, m_auth, sizeof(m_auth)) == 0;
			}
		}
		return FALSE;
	}

	command bool CheckAuth.empty() {
		uint8_t i;
		for(i=0;i<sizeof(m_auth);i++) {
			if(i != 0) {
				return FALSE;
			}
		}
		return TRUE;
	}

}
