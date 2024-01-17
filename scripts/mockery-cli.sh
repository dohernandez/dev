#!/usr/bin/env bash

[ -z "$MOCKERY_VERSION" ] && echo "mockery version is required" && exit 1

# detecting GOPATH and removing trailing "/" if any
GOPATH="$(go env GOPATH)"
GOPATH=${GOPATH%/}

# adding GOBIN to PATH
[[ ":$PATH:" != *"$GOPATH/bin"* ]] && PATH=$PATH:"$GOPATH"/bin

# checking if mockery is available and it is the version specify without the version prefix.
if command -v mockery >/dev/null; then
  version_installed="$(mockery --version --quiet | cut -d' ' -f2)"

  version="${MOCKERY_VERSION}"

  if [[ version == v* ]]; then
    version="${version:1}"
  fi

  if [ "${version_installed}" = "${version}" ]; then \
    exit 0
  fi
fi

# checking if mockery is available and it is the version specify
if ! command -v mockery-"$MOCKERY_VERSION" > /dev/null; then \
    echo ">> Installing mockery $MOCKERY_VERSION...";

    if [ "$DRY_RUN" = "true" ]; then
      exit 0
    fi

    platform="$(uname -s)"
    hardware=$(uname -m)

   version="${MOCKERY_VERSION}"

    if [[ version == v* ]]; then
      version="${version:1}"
    fi

    mkdir -p /tmp/mockery-"$MOCKERY_VERSION"

    curl -sL https://github.com/vektra/mockery/releases/download/"$MOCKERY_VERSION"/mockery_"$version"_"$platform"_"$hardware".tar.gz | tar xvz -C /tmp/mockery-"$MOCKERY_VERSION" \
        && mv /tmp/mockery-"$MOCKERY_VERSION"/mockery "$GOPATH"/bin/mockery-"$MOCKERY_VERSION"
fi
