GO ?= go

PROTOBUF_VERSION="v25.2"
PROTOC_GEN_GO_VERSION="v1.28.0"
PROTOC_GEN_GO_GRPC_VERSION="v1.3.0"

## Check/install protoc tool
protoc-cli:
	@PROTOBUF_VERSION=$(PROTOBUF_VERSION) bash $(EXTEND_DEVGO_SCRIPTS)/protoc-cli.sh

## Check/install protoc-gen plugin
protoc-gen-cli:
	@PROTOC_GEN_GO_VERSION=$(PROTOC_GEN_GO_VERSION) bash $(EXTEND_DEVGO_SCRIPTS)/protoc-gen-cli.sh

## Check/install protoc-gen-grpc plugin
protoc-gen-grpc-cli:
	@PROTOC_GEN_GO_GRPC_VERSION=$(PROTOC_GEN_GO_GRPC_VERSION) bash $(EXTEND_DEVGO_SCRIPTS)/protoc-gen-grpc-cli.sh

.PHONY: protoc-cli protoc-gen-cli protoc-gen-grpc-cli
