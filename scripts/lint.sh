#!/usr/bin/env bash

[ -z "$GO" ] && GO=go
[ -z "$LINT_PATH" ] && LINT_PATH="."
[ -z "$GOLANGCI_LINT_VERSION" ] && echo "golangci-lint version is required" && exit 1


# detecting GOPATH and removing trailing "/" if any
GOPATH="$(go env GOPATH)"
GOPATH=${GOPATH%/}

# adding GOBIN to PATH
[[ ":$PATH:" != *"$GOPATH/bin"* ]] && PATH=$PATH:"$GOPATH"/bin

this_path=$(dirname "$0")

golangci_yml="./.golangci.yml"
if [ ! -f "./.golangci.yml" ]; then
  golangci_yml="$this_path"/.golangci.yml
fi

if command -v golangci-lint >/dev/null; then
  version_installed="$(golangci-lint --version | sed 's/[^0-9.]*\([0-9.]*\).*/\1/')"

    version="${GOLANGCI_LINT_VERSION}"

    if [[ version == v* ]]; then
      version="${version:1}"
    fi

    if [ "${version_installed}" = "${version}" ]; then \
      echo "Checking packages..."
      golangci-lint run -c "$golangci_yml" "$LINT_PATH"/... || exit 1

      exit 0
    fi
elif ! command -v golangci-lint-"$GOLANGCI_LINT_VERSION" >/dev/null; then
    echo "golangci-lint $GOLANGCI_LINT_VERSION is not installed"

    exit 1
fi

echo "Checking packages..."
golangci-lint-"$GOLANGCI_LINT_VERSION" run -c "$golangci_yml" "$LINT_PATH"/... || exit 1
