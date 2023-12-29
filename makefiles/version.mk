#-## Print the version number of make dev tools.

.PHONY: version

GO ?= go

## Print the version number of dev tools.
version:
	@echo "Make dev $(shell $(GO) list -f '{{.Version}}' -m github.com/dohernandez/dev)"
