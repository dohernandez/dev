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
  ifneq "$(wildcard ./vendor/github.com/dohernadez/dev)" ""
  	EXTEND_DEVGO_PATH := ./vendor/github.com/dohernadez/dev
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
-include $(EXTEND_DEVGO_PATH)/makefiles/receipt.mk

# Start extra receipts here.
-include $(DEVGO_PATH)/makefiles/lint.mk
-include $(EXTEND_DEVGO_PATH)/makefiles/pg.mk
# End extra receipts here.

.PHONY: test check

# DO NOT EDIT ANYTHING BELOW THIS LINE.

# Add your custom targets here.

## Run lint
check: lint
