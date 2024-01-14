#!/usr/bin/env bash

[ -z "$GO" ] && GO=go
[ -z "$GOFUMPT_VERSION" ] && echo "gofumpt version is required" && exit 1

# detecting GOPATH and removing trailing "/" if any
GOPATH="$(go env GOPATH)"
GOPATH=${GOPATH%/}

# adding GOBIN to PATH
[[ ":$PATH:" != *"$GOPATH/bin"* ]] && PATH=$PATH:"$GOPATH"/bin

# checking if gofumpt is available and it is the version specify without the version prefix.
if command -v gofumpt >/dev/null; then
    version_installed="$(gofumpt --version)"

    version="${GOFUMPT_VERSION}"

    if [[ version == v* ]]; then
        version="${version:1}"
    fi

    if [ "${version_installed}" = "${version}" ]; then \
        exit 0
    fi
fi

# checking if gofumpt is available and it is the version specify
# gofumpt is a drop-in replacement for gofmt with stricter formatting: https://github.com/mvdan/gofumpt
if ! command -v gofumpt-"$GOFUMPT_VERSION" > /dev/null; then \
  echo ">> Installing gofumpt $GOFUMPT_VERSION..."; \

  # Check if gofumpt binary exists and save tmp
  if [ -f "$GOPATH"/bin/gofumpt ]; then
      mv "$GOPATH"/bin/gofumpt "$GOPATH"/bin/gofumpt-tmp;
  fi

  $GO install mvdan.cc/gofumpt@"$GOFUMPT_VERSION";

  # Restore gofumpt binary
  if [ -f "$GOPATH"/bin/gofumpt-tmp ]; then
      mv "$GOPATH"/bin/gofumpt-tmp "$GOPATH"/bin/gofumpt;
  fi
fi