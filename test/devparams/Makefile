#
# Makefile for test application.
# @author Raido Pahtma
# @license MIT
#
COMPONENT=TestDeviceParametersC

MAKEFILE_LOCATION := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# Avoid strange TinyOS issues
PFLAGS += -DTASKLET_IS_TASK

PFLAGS += -I$(MAKEFILE_LOCATION)
PFLAGS += -I$(MAKEFILE_LOCATION)/../../tos/interfaces
PFLAGS += -I$(MAKEFILE_LOCATION)/../../tos/devparams
PFLAGS += -I$(MAKEFILE_LOCATION)/../../tos/lib/devparam
PFLAGS += -I$(MAKEFILE_LOCATION)/../../tos/lib/nvstorage
PFLAGS += -I$(MAKEFILE_LOCATION)/../../tos/lib/net

# Get the MainC that configures correct boot sequence
PFLAGS += -I$(MAKEFILE_LOCATION)/../nvstorage

PFLAGS += -I$(WORKSPACE_ROOT)/submodule.tosrfxsecond/tos

BASE_LOG_LEVEL ?= 0xFFFF
PLATFORM_BAUDRATE ?= 500000UL
PRINTF_BUFFER_SIZE ?= 4000
PRINTF_PORT = 1

PFLAGS += -DTOSH_DATA_LENGTH=114
RADIO_CHANNEL ?= 11

PFLAGS += -DSW_MAJOR_VERSION=0
PFLAGS += -DSW_MINOR_VERSION=0
PFLAGS += -DSW_PATCH_VERSION=0

PFLAGS += -Wsign-compare
PFLAGS += -Wextra
PFLAGS += -Wno-unused-parameter

include $(TINYOS_ROOT_DIR)/Makefile.include
$(call TOSMake_include,extras/groundlib.extra)
$(call TOSMake_include,extras/watchdogs.extra)
