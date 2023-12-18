GO ?= go

PWD = $(shell pwd)

# Detecting GOPATH and removing trailing "/" if any
GOPATH = $(realpath $(shell $(GO) env GOPATH))

ifneq "$(wildcard ./vendor )" ""
  modVendor = -mod=vendor

  ifneq "$(wildcard ./vendor/github.com/bool64/dev)" ""
    	DEVGO_PATH := ./vendor/github.com/bool64/dev
    endif
endif

ifeq ($(DEVGO_PATH),)
	DEVGO_PATH := $(shell GO111MODULE=on $(GO) list ${modVendor} -f '{{.Dir}}' -m github.com/bool64/dev)
	ifeq ($(DEVGO_PATH),)
    	$(info Module github.com/bool64/dev not found, downloading.)
    	DEVGO_PATH := $(shell export GO111MODULE=on && $(GO) get github.com/bool64/dev && $(GO) list -f '{{.Dir}}' -m github.com/bool64/dev)
	endif
endif

export MODULE_NAME := $(shell test -f go.mod && GO111MODULE=on $(GO) list $(modVendor) -m)

EXTEND_DEVGO_PATH ?= $(PWD)/vendor/github.com/dohernandez/dev
EXTEND_DEVGO_SCRIPTS ?= $(EXTEND_DEVGO_PATH)/scripts

-include $(DEVGO_PATH)/makefiles/main.mk
