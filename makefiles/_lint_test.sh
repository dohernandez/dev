#!/bin/bash

[ -z "$tmake" ] && tmake="make"
OUTPUT_PATH="$ROOT_PATH/makefiles/testdata/output/lint"

GOLANGCI_LINT_VERSION="1.55.2"
GCI_VERSION="0.12.1"
GOFUMPT_VERSION="v0.5.0"

Test_make_recipe_enable_lint() {
  printf "Test make recipe-enable lint -> "
  # Create a files for test
  create_files_test
  # Run enable recipe lint
  $tmake enable-recipe PACKAGE=dev NAME=lint > "$TEST_OUTPUT"
  # Run make test
  $tmake >> "$TEST_OUTPUT"
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-recipe-enable-lint.output"

  echo "OK"
}

lint_cli_version_exists_without_prefix() {
  version="$1"

  # checking if golangci-lint is available without the version prefix.
  if command -v golangci-lint >/dev/null; then
    version_installed="$(golangci-lint --version | sed 's/[^0-9.]*\([0-9.]*\).*/\1/')"

    if [[ version == v* ]]; then
      version="${version:1}"
    fi

    if [ "${version_installed}" = "${version}" ]; then \
      echo "true"
      exit 0
    fi
  fi

  echo "false"
}

backup_lint_cli_without_prefix() {
  version="$1"

  path=$(which golangci-lint)

  mv "$path" "$path".bak

  echo "$path".bak
}

lint_cli_version_exists_with_prefix() {
  version="$1"

  # checking if golangci-lint is available with the version prefix.
  if command -v golangci-lint-"v$version" >/dev/null; then
    echo "true"
    exit 0
  fi

  echo "false"
}

backup_lint_cli_with_prefix() {
  version="$1"

  path=$(which golangci-lint-"v$version")

  mv "$path" "$path".bak

  echo "$path".bak
}

restore_binary() {
  path="$1"

  mv "$path" "${path%.bak}"
}

Test_make_lint_cli() {
  printf "Test make lint-cli -> "
  # Create a files for test
  create_files_test
  # Run enable recipe lint
  $tmake enable-recipe PACKAGE=dev NAME=lint > /dev/null
  # Prepare the test
  restore=
  if [ "$(lint_cli_version_exists_without_prefix "$GOLANGCI_LINT_VERSION")" = "true" ]; then
    restore=$(backup_lint_cli_without_prefix "$GOLANGCI_LINT_VERSION")
  elif [ "$(lint_cli_version_exists_with_prefix "$GOLANGCI_LINT_VERSION")" = "true" ]; then
    restore=$(backup_lint_cli_with_prefix "$GOLANGCI_LINT_VERSION")
  fi
  # Run make test
  $tmake -e DRY_RUN=true lint-cli > "$TEST_OUTPUT" 2>&1
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-lint-cli.output"

  if [ -n "$restore"  ]; then
    restore_binary "$restore"
  fi

  echo "OK"
}

Test_make_lint_cli_installed() {
  printf "Test make lint-cli but installed -> "
  # Create a files for test
  create_files_test
  # Run enable recipe lint
  $tmake enable-recipe PACKAGE=dev NAME=lint > /dev/null
  # Prepare the test
  restore=
  if [ "$(lint_cli_version_exists_without_prefix "$GOLANGCI_LINT_VERSION")" = "true" ]; then
    restore=$(backup_lint_cli_without_prefix "$GOLANGCI_LINT_VERSION")
  elif [ "$(lint_cli_version_exists_with_prefix "$GOLANGCI_LINT_VERSION")" = "true" ]; then
    restore=$(backup_lint_cli_with_prefix "$GOLANGCI_LINT_VERSION")
  fi
  $tmake lint-cli > /dev/null 2>&1
  # Run make test (try to install the cli but it is already installed)
  $tmake lint-cli > "$TEST_OUTPUT"
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_empty_output "$TEST_OUTPUT"

  if [ -n "$restore"  ]; then
    restore_binary "$restore"
  fi

  echo "OK"
}

gci_cli_version_exists_without_prefix() {
  version="$1"

  # checking if gci is available without the version prefix.
  if command -v gci >/dev/null; then
    version_installed="$(gci --version | cut -d' ' -f3)"

    if [[ version == v* ]]; then
      version="${version:1}"
    fi

    if [ "${version_installed}" = "${version}" ]; then \
      echo "true"
      exit 0
    fi
  fi

  echo "false"
}

backup_gci_cli_without_prefix() {
  version="$1"

  path=$(which gci)

  mv "$path" "$path".bak

  echo "$path".bak
}

gci_cli_version_exists_with_prefix() {
  version="$1"

  # checking if gci is available with the version prefix.
  if command -v gci-"v$version" >/dev/null; then
    echo "true"
    exit 0
  fi

  echo "false"
}

backup_gci_cli_with_prefix() {
  version="$1"

  path=$(which gci-"v$version")

  mv "$path" "$path".bak

  echo "$path".bak
}

Test_make_gci_cli() {
  printf "Test make gci-cli -> "
  # Create a files for test
  create_files_test
  # Run enable recipe gci
  $tmake enable-recipe PACKAGE=dev NAME=lint > /dev/null
  # Prepare the test
  restore=
  if [ "$(gci_cli_version_exists_without_prefix "$GCI_VERSION")" = "true" ]; then
    restore=$(backup_gci_cli_without_prefix "$GCI_VERSION")
  elif [ "$(gci_cli_version_exists_with_prefix "$GCI_VERSION")" = "true" ]; then
    restore=$(backup_gci_cli_with_prefix "$GCI_VERSION")
  fi
  # Run make test
  $tmake -e DRY_RUN=true gci-cli > "$TEST_OUTPUT" 2>&1
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-gci-cli.output"

  if [ -n "$restore"  ]; then
    restore_binary "$restore"
  fi

  echo "OK"
}

Test_make_gci_cli_installed() {
  printf "Test make gci-cli but installed -> "
  # Create a files for test
  create_files_test
  # Run enable recipe gci
  $tmake enable-recipe PACKAGE=dev NAME=lint > /dev/null
  # Prepare the test
  restore=
  if [ "$(gci_cli_version_exists_without_prefix "$GCI_VERSION")" = "true" ]; then
    restore=$(backup_gci_cli_without_prefix "$GCI_VERSION")
  elif [ "$(gci_cli_version_exists_with_prefix "$GCI_VERSION")" = "true" ]; then
    restore=$(backup_gci_cli_with_prefix "$GCI_VERSION")
  fi
  $tmake gci-cli > /dev/null 2>&1
  # Run make test (try to install the cli but it is already installed)
  $tmake gci-cli > "$TEST_OUTPUT"
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_empty_output "$TEST_OUTPUT"

  if [ -n "$restore"  ]; then
    restore_binary "$restore"
  fi

  echo "OK"
}

gofumpt_cli_version_exists_without_prefix() {
  version="$1"

  # checking if gofumpt is available without the version prefix.
  if command -v gofumpt >/dev/null; then
    version_installed="$(gofumpt --version)"

    if [[ version == v* ]]; then
      version="${version:1}"
    fi

    if [ "${version_installed}" = "${version}" ]; then \
      echo "true"
      exit 0
    fi
  fi

  echo "false"
}

backup_gofumpt_cli_without_prefix() {
  version="$1"

  path=$(which gofumpt)

  mv "$path" "$path".bak

  echo "$path".bak
}

gofumpt_cli_version_exists_with_prefix() {
  version="$1"

  # checking if gofumpt is available with the version prefix.
  if command -v gofumpt-"v$version" >/dev/null; then
    echo "true"
    exit 0
  fi

  echo "false"
}

backup_gofumpt_cli_with_prefix() {
  version="$1"

  path=$(which gofumpt-"v$version")

  mv "$path" "$path".bak

  echo "$path".bak
}

Test_make_gofumpt_cli() {
  printf "Test make gofumpt-cli -> "
  # Create a files for test
  create_files_test
  # Run enable recipe gofumpt
  $tmake enable-recipe PACKAGE=dev NAME=lint > /dev/null
  # Prepare the test
  restore=
  if [ "$(gofumpt_cli_version_exists_without_prefix "$GOFUMPT_VERSION")" = "true" ]; then
    restore=$(backup_gofumpt_cli_without_prefix "$GOFUMPT_VERSION")
  elif [ "$(gofumpt_cli_version_exists_with_prefix "$GOFUMPT_VERSION")" = "true" ]; then
    restore=$(backup_gofumpt_cli_with_prefix "$GOFUMPT_VERSION")
  fi
  # Run make test
  $tmake -e DRY_RUN=true gofumpt-cli > "$TEST_OUTPUT" 2>&1
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-gofumpt-cli.output"

  if [ -n "$restore"  ]; then
    restore_binary "$restore"
  fi

  echo "OK"
}

Test_make_gofumpt_cli_installed() {
  printf "Test make gofumpt-cli but installed -> "
  # Create a files for test
  create_files_test
  # Run enable recipe gofumpt
  $tmake enable-recipe PACKAGE=dev NAME=lint > /dev/null
  # Prepare the test
  restore=
  if [ "$(gofumpt_cli_version_exists_without_prefix "$GOFUMPT_VERSION")" = "true" ]; then
    restore=$(backup_gofumpt_cli_without_prefix "$GOFUMPT_VERSION")
  elif [ "$(gofumpt_cli_version_exists_with_prefix "$GOFUMPT_VERSION")" = "true" ]; then
    restore=$(backup_gofumpt_cli_with_prefix "$GOFUMPT_VERSION")
  fi
  $tmake gci-cli > /dev/null 2>&1
  # Run make test (try to install the cli but it is already installed)
  $tmake gci-cli > "$TEST_OUTPUT"
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_empty_output "$TEST_OUTPUT"

  if [ -n "$restore"  ]; then
    restore_binary "$restore"
  fi

  echo "OK"
}

Test_make_lint() {
  printf "Test make lint -> "
  # Create a files for test
  create_files_test
  # Run enable recipe gofumpt
  $tmake enable-recipe PACKAGE=dev NAME=lint > /dev/null
  # Prepare the test
  restore=
  if [ "$(gofumpt_cli_version_exists_without_prefix "$GOFUMPT_VERSION")" = "true" ]; then
    restore=$(backup_gofumpt_cli_without_prefix "$GOFUMPT_VERSION")
  elif [ "$(gofumpt_cli_version_exists_with_prefix "$GOFUMPT_VERSION")" = "true" ]; then
    restore=$(backup_gofumpt_cli_with_prefix "$GOFUMPT_VERSION")
  fi
  $tmake gci-cli > /dev/null 2>&1
  # Running command to test
  $tmake -e LINT_PATH=./gotest lint > "$TEST_OUTPUT" 2>&1
  if [ $? -eq 0 ]; then
      echo "make should fail"
      exit 1
  fi
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-lint.output"

  if [ -n "$restore"  ]; then
    restore_binary "$restore"
  fi

  echo "OK"
}