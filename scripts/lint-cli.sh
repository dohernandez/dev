#!/usr/bin/env bash

[ -z "$GOLANGCI_LINT_VERSION" ] && echo "golangci-lint version is required" && exit 1

# detecting GOPATH and removing trailing "/" if any
GOPATH="$(go env GOPATH)"
GOPATH=${GOPATH%/}

# adding GOBIN to PATH
[[ ":$PATH:" != *"$GOPATH/bin"* ]] && PATH=$PATH:"$GOPATH"/bin

# checking if golangci-lint is available and it is the version specify without the version prefix.
if command -v golangci-lint >/dev/null; then
  version_installed="$(golangci-lint --version | sed 's/[^0-9.]*\([0-9.]*\).*/\1/')"

  version="${GOLANGCI_LINT_VERSION}"

  if [[ version == v* ]]; then
    version="${version:1}"
  fi

  if [ "${version_installed}" = "${version}" ]; then \
    exit 0
  fi
fi

# checking if golangci-lint is available and it is the version specify but with the version prefix, otherwise install it.
if ! command -v golangci-lint-"$GOLANGCI_LINT_VERSION" >/dev/null; then
  echo ">> Installing golangci-lint $GOLANGCI_LINT_VERSION...";

  if [ "$DRY_RUN" = "true" ]; then
    exit 0
  fi

  curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /tmp/golangci-lint-"$GOLANGCI_LINT_VERSION" "$GOLANGCI_LINT_VERSION" \
              && mv /tmp/golangci-lint-"$GOLANGCI_LINT_VERSION"/golangci-lint "$GOPATH"/bin/golangci-lint-"$GOLANGCI_LINT_VERSION"
fi