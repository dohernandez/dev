#-## Utilities for testing code

#- Placeholders require include the file in the Makefile
#- require - dev/test

BEFORE_TEST_TARGETS += test-local

TEST_SUITE = "testdata"

## Run tests local
test-local:
	@echo "Running tests local..."

.PHONY: test-local