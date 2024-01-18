#!/usr/bin/env bash

[ -z "$GO" ] && GO=go
[ -z "$PROTOC_GEN_GO_VERSION" ] && echo "protoc-gen-go version is required" && exit 1

# detecting GOPATH and removing trailing "/" if any
GOPATH="$(go env GOPATH)"
GOPATH=${GOPATH%/}

# adding GOBIN to PATH
[[ ":$PATH:" != *"$GOPATH/bin"* ]] && PATH=$PATH:"$GOPATH"/bin

# checking if protoc-gen-go is available and it is the version specify without the version prefix.
if command -v protoc-gen-go >/dev/null; then
  version_installed="$(protoc-gen-go --version | cut -d' ' -f2)"

  version="${PROTOC_GEN_GO_VERSION}"

  if [ "${version_installed}" = "${version}" ]; then \
    exit 0
  fi
fi

# checking if protoc-gen-go is available
if ! command -v protoc-gen-go-"$PROTOC_GEN_GO_VERSION" > /dev/null; then \
    echo ">> Installing protoc-gen-go $PROTOC_GEN_GO_VERSION... "; \

    if [ "$DRY_RUN" = "true" ]; then
      exit 0
    fi

    # Check if gofumpt binary exists and save tmp
    if [ -f "$GOPATH"/bin/protoc-gen-go ]; then
        mv "$GOPATH"/bin/protoc-gen-go "$GOPATH"/bin/protoc-gen-go-tmp;
    fi

    $GO install google.golang.org/protobuf/cmd/protoc-gen-go@"$PROTOC_GEN_GO_VERSION";
    mv "$GOPATH/bin"/protoc-gen-go "$GOPATH"/bin/protoc-gen-go-"$PROTOC_GEN_GO_VERSION";

    # Restore gofumpt binary
    if [ -f "$GOPATH"/bin/protoc-gen-go-tmp ]; then
        mv "$GOPATH"/bin/protoc-gen-go-tmp "$GOPATH"/bin/protoc-gen-go;
    fi
fi
