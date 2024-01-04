#-## Utilities for check the code

#- Placeholders require include the file in the Makefile
#- require - dev/check
#- require - self/test

CHECK_TARGETS = "test"

BEFORE_CHECK_TARGETS += before-check-requirements

## Run before check requirements local
before-check-requirements:
	@echo "Running before check requirements..."

AFTER_CHECK_TARGETS += after-check-requirements

## Run after check requirements local
after-check-requirements:
	@echo "Running after check requirements..."

.PHONY: check-requirements after-check-requirements