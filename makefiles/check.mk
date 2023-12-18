#-## Utilities for checking code

-include $(DEVGO_PATH)/makefiles/lint.mk
-include $(DEVGO_PATH)/makefiles/test-unit.mk

## Run lint and test
check: lint test-unit