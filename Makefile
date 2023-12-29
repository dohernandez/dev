#GOLANGCI_LINT_VERSION := "v1.55.2" # Optional configuration to pinpoint golangci-lint version.

# The head of Makefile determines location of dev-go to include standard targets.
GO ?= go
export GO111MODULE = on

ifneq "$(wildcard ./vendor )" ""
  modVendor =  -mod=vendor
  ifeq (,$(findstring -mod,$(GOFLAGS)))
      export GOFLAGS := ${GOFLAGS} ${modVendor}
  endif
endif

ifeq ($(EXTEND_DEVGO_PATH),)
	EXTEND_DEVGO_PATH := $(shell GO111MODULE=on $(GO) list ${modVendor} -f '{{.Dir}}' -m github.com/dohernandez/dev)
	ifeq ($(EXTEND_DEVGO_PATH),)
    	$(info Module github.com/dohernandez/dev not found, downloading.)
    	EXTEND_DEVGO_PATH := $(shell export GO111MODULE=on && $(GO) get github.com/dohernandez/dev && $(GO) list -f '{{.Dir}}' -m github.com/dohernandez/dev)
	endif
endif

-include $(EXTEND_DEVGO_PATH)/makefiles/main.mk

# Start extra recipes here.
# End extra recipes here.

# DO NOT EDIT ANYTHING BELOW THIS LINE.

# Add your custom targets here.

.PHONY: test

## Run tests
test:
	@echo "Running unit tests"
	@bash _Makefile_test.sh
