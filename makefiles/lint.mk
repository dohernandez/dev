GO ?= go

# Override in app main.mk to control lint version.
GOLANGCI_LINT_VERSION ?= "v1.55.2"
# Override in app main.mk to control gci version.
GCI_VERSION ?= "v0.12.1"
# Override in app main.mk to control gofumpt version.
GOFUMPT_VERSION ?= "v0.5.0"

# Override in app main.mk to control lint path.
LINT_PATH ?= .

# Override in app main.mk to control cmd lint path.
CMD_LINT_PATH ?= ./*/cmd

## Check/install golangci-lint version tool; GOLANGCI_LINT_VERSION
lint-cli:
	@GOLANGCI_LINT_VERSION=$(GOLANGCI_LINT_VERSION) DRY_RUN=$(DRY_RUN) bash $(EXTEND_DEVGO_SCRIPTS)/lint-cli.sh

## Check with golangci-lint
lint: lint-cli
	@GOLANGCI_LINT_VERSION=$(GOLANGCI_LINT_VERSION) LINT_PATH=$(LINT_PATH) CMD_LINT_PATH=$(CMD_LINT_PATH) bash $(EXTEND_DEVGO_SCRIPTS)/lint.sh

## Check/install gci tool
gci-cli:
	@GCI_VERSION=$(GCI_VERSION) DRY_RUN=$(DRY_RUN) bash $(EXTEND_DEVGO_SCRIPTS)/gci-cli.sh

## Check/install gofumpt tool
gofumpt-cli:
	@GOFUMPT_VERSION=$(GOFUMPT_VERSION) DRY_RUN=$(DRY_RUN) bash $(EXTEND_DEVGO_SCRIPTS)/gofumpt-cli.sh

## Apply goimports and gofmt
fix-lint: gci-cli gofumpt-cli
	@GCI_VERSION=$(GCI_VERSION) GOFUMPT_VERSION=$(GOFUMPT_VERSION) bash $(EXTEND_DEVGO_SCRIPTS)/fix.sh

.PHONY: lint-cli gci-cli gofumpt-cli lint fix-lint