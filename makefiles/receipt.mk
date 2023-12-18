GO ?= go

FILES := $(wildcard $(PWD)/$(DEVGO_PATH)/makefiles/*.mk $(PWD)/makefiles/*.mk)

## List all available receipts
list-receipts:
	@echo "Available receipt to enable:"
	@PWD=$(PWD) \
	EXTEND_DEVGO_PATH=$(EXTEND_DEVGO_PATH) \
	DEVGO_PATH=$(DEVGO_PATH) \
	FILES="$(FILES)" \
	bash $(EXTEND_DEVGO_SCRIPTS)/list-receipts.sh


## Enable a receipt into Makefile
enable-receipt:
	@echo "Enabling receipt: $(NAME)"
	@NAME=$(NAME) \
	DEVGO_PATH=$(DEVGO_PATH) \
	EXTEND_DEVGO_PATH=$(EXTEND_DEVGO_PATH) \
	bash $(EXTEND_DEVGO_SCRIPTS)/enable-receipt.sh











