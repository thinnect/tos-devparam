/**
 * Non-volatile parameter storage interface.
 *
 * @author Raido Pahtma
 * @license MIT
 */
interface NvParameter {

	// Confirm name match - parameter lookup by name
	event bool matches(const char* identifier);

	// Fired before boot to initialize the parameter value
	event error_t init(uint8_t* pvalue, uint8_t vlen);

	// Store the value
	command error_t store(const char* identifier, uint8_t* pvalue, uint8_t vlen);

}
