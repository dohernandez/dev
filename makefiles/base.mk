#GOLANGCI_LINT_VERSION := "v1.55.2" # Optional configuration to pinpoint golangci-lint version.

# The head of Makefile determines location of dev-go to include standard targets.
GO ?= go
export GO111MODULE = on

ifneq "$(GOFLAGS)" ""
  $(info GOFLAGS: ${GOFLAGS})
endif

ifneq "$(wildcard ./vendor )" ""
  $(info Using vendor)
  modVendor =  -mod=vendor
  ifeq (,$(findstring -mod,$(GOFLAGS)))
      export GOFLAGS := ${GOFLAGS} ${modVendor}
  endif
  ifneq "$(wildcard ./vendor/github.com/bool64/dev)" ""
  	DEVUPSTREAMGO_PATH := ./vendor/github.com/bool64/dev
  endif
  ifneq "$(wildcard ./vendor/github.com/dohernadez/dev)" ""
  	DEVGO_PATH := ./vendor/github.com/dohernadez/dev
  endif
endif

ifeq ($(DEVUPSTREAMGO_PATH),)
	DEVUPSTREAMGO_PATH := $(shell GO111MODULE=on $(GO) list ${modVendor} -f '{{.Dir}}' -m github.com/bool64/dev)
	ifeq ($(DEVGO_PATH),)
    	$(info Module github.com/bool64/dev not found, downloading.)
    	DEVGO_PATH := $(shell export GO111MODULE=on && $(GO) get github.com/bool64/dev && $(GO) list -f '{{.Dir}}' -m github.com/bool64/dev)
	endif
endif

ifeq ($(DEVGO_PATH),)
	DEVGO_PATH := $(shell GO111MODULE=on $(GO) list ${modVendor} -f '{{.Dir}}' -m github.com/dohernandez/dev)
	ifeq ($(DEVGO_PATH),)
    	$(info Module github.com/dohernandez/dev not found, downloading.)
    	DEVGO_PATH := $(shell export GO111MODULE=on && $(GO) get github.com/dohernandez/dev && $(GO) list -f '{{.Dir}}' -m github.com/dohernandez/dev)
	endif
endif

-include $(DEVUPSTREAMGO_PATH)/makefiles/main.mk
-include $(DEVUPSTREAMGO_PATH)/makefiles/lint.mk
-include $(DEVUPSTREAMGO_PATH)/makefiles/test-unit.mk
-include $(DEVUPSTREAMGO_PATH)/makefiles/bench.mk
-include $(DEVUPSTREAMGO_PATH)/makefiles/reset-ci.mk
-include $(DEVGO_PATH)/makefiles/pg.mk

.PHONY: test check

# Add your custom targets here.

## Run tests
test: pg-ready test-unit

## Run lint and test
check: lint test