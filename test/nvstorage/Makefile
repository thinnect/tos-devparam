#
# Makefile for test application.
# @author Raido Pahtma
# @license MIT
#
COMPONENT=TestNvParametersC

MAKEFILE_LOCATION := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# Avoid strange TinyOS issues
PFLAGS += -DTASKLET_IS_TASK

PFLAGS += -I$(MAKEFILE_LOCATION)
PFLAGS += -I$(MAKEFILE_LOCATION)/../../tos/nvstorage

BASE_LOG_LEVEL ?= 0xFFFF
PLATFORM_BAUDRATE ?= 500000UL
PRINTF_BUFFER_SIZE ?= 4000

PFLAGS += -Wsign-compare
PFLAGS += -Wextra
PFLAGS += -Wno-unused-parameter

include $(TINYOS_ROOT_DIR)/Makefile.include
$(call TOSMake_include,extras/groundlib.extra)
