#!/usr/bin/env bash

[ -z "$GO" ] && GO=go
[ -z "$PROTOC_GEN_GO_GRPC_VERSION" ] && echo "protoc-gen-go-grpc version is required" && exit 1

# detecting GOPATH and removing trailing "/" if any
GOPATH="$(go env GOPATH)"
GOPATH=${GOPATH%/}

# adding GOBIN to PATH
[[ ":$PATH:" != *"$GOPATH/bin"* ]] && PATH=$PATH:"$GOPATH"/bin

# checking if protoc-gen-go-grpc is available and it is the version specify without the version prefix.
if command -v protoc-gen-go-grpc >/dev/null; then
  version_installed="$(protoc-gen-go-grpc --version | cut -d' ' -f2)"

  version="${PROTOC_GEN_GO_GRPC_VERSION}"

  if [[ version == v* ]]; then
    version="${version:1}"
  fi

  if [ "${version_installed}" = "${version}" ]; then \
    exit 0
  fi
fi

# checking if protoc-gen-go-grpc is available
if ! command -v protoc-gen-go-grpc-"$PROTOC_GEN_GO_GRPC_VERSION" > /dev/null; then \
    echo ">> Installing protoc-gen-go-grpc $PROTOC_GEN_GO_GRPC_VERSION... "; \

    if [ "$DRY_RUN" = "true" ]; then
      exit 0
    fi

    # Check if gofumpt binary exists and save tmp
    if [ -f "$GOPATH"/bin/protoc-gen-go-grpc ]; then
        mv "$GOPATH"/bin/protoc-gen-go-grpc "$GOPATH"/bin/protoc-gen-go-grpc-tmp;
    fi

    $GO install google.golang.org/grpc/cmd/protoc-gen-go-grpc@"$PROTOC_GEN_GO_GRPC_VERSION";
    mv "$GOPATH/bin"/protoc-gen-go-grpc "$GOPATH"/bin/protoc-gen-go-grpc-"$PROTOC_GEN_GO_GRPC_VERSION";

    # Restore gofumpt binary
    if [ -f "$GOPATH"/bin/protoc-gen-go-grpc-tmp ]; then
        mv "$GOPATH"/bin/protoc-gen-go-grpc-tmp "$GOPATH"/bin/protoc-gen-go-grpc;
    fi
fi
