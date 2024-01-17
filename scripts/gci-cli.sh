#!/usr/bin/env bash

[ -z "$GO" ] && GO=go
[ -z "$GCI_VERSION" ] && echo "cgi version is required" && exit 1

# detecting GOPATH and removing trailing "/" if any
GOPATH="$(go env GOPATH)"
GOPATH=${GOPATH%/}

# adding GOBIN to PATH
[[ ":$PATH:" != *"$GOPATH/bin"* ]] && PATH=$PATH:"$GOPATH"/bin

# checking if gci is available and it is the version specify without the version prefix.
if command -v gci >/dev/null; then
    version_installed="$(gci --version | cut -d' ' -f3)"

    version="${GCI_VERSION}"

    if [[ version == v* ]]; then
        version="${version:1}"
    fi

    if [ "${version_installed}" = "${version}" ]; then \
        exit 0
    fi
fi

# checking if gci is available and it is the version specify but with the version prefix,
# otherwise install it. https://github.com/daixiang0/gci
if ! command -v gci-$GCI_VERSION > /dev/null; then \
    echo ">> Installing gci $GCI_VERSION..."; \

    if [ "$DRY_RUN" = "true" ]; then
      exit 0
    fi

    # Check if gci binary exists and save tmp
    if [ -f "$GOPATH"/bin/gci ]; then
        mv "$GOPATH"/bin/gci "$GOPATH"/bin/gci-tmp;
    fi

    $GO install -mod=mod github.com/daixiang0/gci@"$GCI_VERSION";
    mv "$GOPATH/bin"/gci "$GOPATH"/bin/gci-"$GCI_VERSION";

    # Restore gci binary
    if [ -f "$GOPATH"/bin/gci-tmp ]; then
        mv "$GOPATH"/bin/gci-tmp "$GOPATH"/bin/gci;
    fi
fi