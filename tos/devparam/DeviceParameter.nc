/**
 * @author Raido Pahtma
 * @license MIT
 **/
interface DeviceParameter {

	command bool matches(const char* identifier);

	command error_t set(void* data, uint8_t length);

	command error_t get();

	event void value(const char* identifier, uint8_t type, void* data, uint8_t length);

}
