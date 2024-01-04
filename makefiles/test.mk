#-## Utilities for testing code

GO ?= go
UNIT_TEST_COUNT ?= 2

# Override in app main.mk to control unit test path.
UNIT_TEST_PATH ?= .

## Run unit tests
test-unit:
	@echo "Running unit tests."
	@CGO_ENABLED=1 $(GO) test -short -coverprofile=unit.coverprofile -covermode=atomic -race $(UNIT_TEST_PATH)/...

## Run unit tests multiple times, use `UNIT_TEST_COUNT=10 make test-unit-multi` to control count
test-unit-multi:
	@echo "Running unit tests ${UNIT_TEST_COUNT} times."
	@CGO_ENABLED=1 $(GO) test -short -coverprofile=unit.coverprofile -count $(UNIT_TEST_COUNT) -covermode=atomic -race $(UNIT_TEST_PATH)/...


#- target-group - BEFORE_TEST_TARGETS:test
BEFORE_TEST_TARGETS :=
#- target-group - TEST_TARGETS:test
TEST_TARGETS := "test-unit"
#- target-group - AFTER_TEST_TARGETS:test
AFTER_TEST_TARGETS :=

## Run all tests belonging to test group
test:
	@echo "Running tests..."
	@for target in $(BEFORE_TEST_TARGETS); do \
		make -f $(MAKEFILE_FILE) -e PLUGIN_MANIFEST_FILE=$(PLUGIN_MANIFEST_FILE) $$target; \
	done

	@for target in $(TEST_TARGETS); do \
		make -f $(MAKEFILE_FILE) -e PLUGIN_MANIFEST_FILE=$(PLUGIN_MANIFEST_FILE) $$target; \
	done

	@for target in $(AFTER_TEST_TARGETS); do \
		make -f $(MAKEFILE_FILE) -e PLUGIN_MANIFEST_FILE=$(PLUGIN_MANIFEST_FILE) $$target; \
	done

.PHONY: test-unit test-unit-multi test