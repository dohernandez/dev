#-## Utilities for checking code

#- require - bool64/dev/lint
#- require - bool64/dev/test-unit

## Run tests
test: test-unit

## Run lint and test
check: lint test

.PHONY: test check