module DeviceParametersSerialP {
	provides {
		interface SerialPacketInfo;
	}
}
implementation {

	async command uint8_t SerialPacketInfo.offset() { return 0; }
	async command uint8_t SerialPacketInfo.dataLinkLength(message_t* msg, uint8_t upperLen) { return upperLen; }
	async command uint8_t SerialPacketInfo.upperLength(message_t* msg, uint8_t dataLinkLen) { return dataLinkLen; }

}
