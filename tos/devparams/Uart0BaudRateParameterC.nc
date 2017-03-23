/**
 * Configurable UART baud rate parameter for AtMega UART1.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include "DeviceParameters.h"
configuration Uart0BaudRateParameterC { }
implementation {

	components new UartBaudRateParameterP(0);

	components Atm128Uart0C as Uart;
	UartBaudRateParameterP.UartBaudRate -> Uart.UartBaudRate;

	components DeviceParametersC;
	DeviceParametersC.DeviceParameter[UQ_DEVICE_PARAMETER_SEQNUM] -> UartBaudRateParameterP.DeviceParameter;

	components new NvParameterC(sizeof(uint32_t)) as NvBaudRate;
	UartBaudRateParameterP.NvParameter -> NvBaudRate.NvParameter;

}
