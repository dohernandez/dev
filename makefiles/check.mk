#-## Utilities for checking code

#- Placeholders require include the file in the Makefile
#- require - bool64/dev/lint
#- require - self/test

#- target-group - BEFORE_CHECK_TARGETS:check
BEFORE_CHECK_TARGETS :=
#- target-group - CHECK_TARGETS:check
CHECK_TARGETS := "lint" "test"
#- target-group - AFTER_CHECK_TARGETS:check
AFTER_CHECK_TARGETS :=

## Run all checks belonging to test check, lint and test
check:
	@echo "Running check..."
	@for target in $(BEFORE_CHECK_TARGETS); do \
		make -f $(MAKEFILE_FILE) -e PLUGIN_MANIFEST_FILE=$(PLUGIN_MANIFEST_FILE) $$target; \
	done

	@for target in $(CHECK_TARGETS); do \
		make -f $(MAKEFILE_FILE) -e PLUGIN_MANIFEST_FILE=$(PLUGIN_MANIFEST_FILE) $$target; \
	done

	@for target in $(AFTER_CHECK_TARGETS); do \
		make -f $(MAKEFILE_FILE) -e PLUGIN_MANIFEST_FILE=$(PLUGIN_MANIFEST_FILE) $$target; \
	done

.PHONY: check