#-## Utilities for checking code

#- Placeholders require include the file in the Makefile
#- require - bool64/dev/lint
#- require - self/test

## Run lint and test
check: lint test

.PHONY: check