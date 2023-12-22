#-## Utilities for checking code

#- require - bool64/dev/lint
#- require - bool64/dev/test-unit

## Run lint and test
check: lint test-unit

.PHONY: check