#!/usr/bin/env bash

[ -z "$PROTOBUF_VERSION" ] && echo "protoc version is required" && exit 1

# detecting GOPATH and removing trailing "/" if any
GOPATH="$(go env GOPATH)"
GOPATH=${GOPATH%/}

# adding GOBIN to PATH
[[ ":$PATH:" != *"$GOPATH/bin"* ]] && PATH=$PATH:"$GOPATH"/bin

# checking if protoc is available and it is the version specify without the version prefix.
if command -v protoc >/dev/null; then
  version_installed="$(protoc --version | cut -d' ' -f2)"

  version="${PROTOBUF_VERSION}"

  if [[ version == v* ]]; then
    version="${version:1}"
  fi

  if [ "${version_installed}" = "${version}" ]; then \
    exit 0
  fi
fi

# checking if protoc is available and it is the version specify
if ! command -v protoc-"$PROTOBUF_VERSION" > /dev/null; then \
    echo ">> Installing protoc $PROTOBUF_VERSION...";

    if [ "$DRY_RUN" = "true" ]; then
      exit 0
    fi

    platform="osx"
    hardware=$(uname -m)

    if [ "$hardware" == "arm64" ]; then \
      hardware="aarch_64"
    fi

   version="${PROTOBUF_VERSION}"

    if [[ version == v* ]]; then
      version="${version:1}"
    fi

    filename=protoc-"$version"-"$platform"-"$hardware".zip

    mkdir -p /tmp/protoc-"$PROTOBUF_VERSION"

    curl -o /tmp/"$filename" -sL https://github.com/protocolbuffers/protobuf/releases/download/"$PROTOBUF_VERSION"/"$filename" \
          && unzip -o /tmp/"$filename" -d /tmp/protoc-"$PROTOBUF_VERSION"

    mkdir -p "$HOME"/protobuf/"$PROTOBUF_VERSION" \
        && mv /tmp/protoc-"$PROTOBUF_VERSION"/* "$HOME"/protobuf/"$PROTOBUF_VERSION"/ \
        && ln -s "$HOME"/protobuf/"$PROTOBUF_VERSION"/bin/protoc "$GOPATH"/bin/protoc-"$PROTOBUF_VERSION"
fi