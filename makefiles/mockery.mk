GO ?= go

# Override in app main.mk to control mockery version.
MOCKERY_VERSION ?= "v2.40.1"

## Check/install mockery tool
mockery-cli:
	@MOCKERY_VERSION=$(MOCKERY_VERSION) bash $(EXTEND_DEVGO_SCRIPTS)/mockery-cli.sh

.PHONY: mockery-cli
