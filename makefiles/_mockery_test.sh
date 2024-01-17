#!/bin/bash

[ -z "$tmake" ] && tmake="make"
OUTPUT_PATH="$ROOT_PATH/makefiles/testdata/output/mockery"

MOCKERY_VERSION="2.40.1"

Test_make_recipe_enable_mockery() {
  printf "Test make recipe-enable mockery -> "
  # Create a files for test
  create_files_test
  # Run enable recipe mockery
  $tmake enable-recipe PACKAGE=dev NAME=mockery > "$TEST_OUTPUT"
  # Run make test
  $tmake >> "$TEST_OUTPUT"
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-recipe-enable-mockery.output"

  echo "OK"
}

mockery_cli_version_exists_without_prefix() {
  version="$1"

  # checking if mockery is available without the version prefix.
  if command -v mockery >/dev/null; then
    version_installed="$(mockery --version --quiet | cut -d' ' -f2)"

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

backup_mockery_cli_without_prefix() {
  version="$1"

  path=$(which mockery)

  mv "$path" "$path".bak

  echo "$path".bak
}

mockery_cli_version_exists_with_prefix() {
  version="$1"

  # checking if mockery is available with the version prefix.
  if command -v mockery-"v$version" >/dev/null; then
    echo "true"
    exit 0
  fi

  echo "false"
}

backup_mockery_cli_with_prefix() {
  version="$1"

  path=$(which mockery-"v$version")

  mv "$path" "$path".bak

  echo "$path".bak
}

restore_binary() {
  path="$1"

  mv "$path" "${path%.bak}"
}

mockery_strip_output() {
  cat "$TEST_OUTPUT" | \
      grep -v "couldn't read any config file" \
      > "$TEST_OUTPUT.tmp" && mv "$TEST_OUTPUT.tmp" "$TEST_OUTPUT"

  strip_output
}

Test_make_mockery_cli() {
  printf "Test make mockery-cli -> "
  # Create a files for test
  create_files_test
  # Run enable recipe mockery
  $tmake enable-recipe PACKAGE=dev NAME=mockery > /dev/null
  # Prepare the test
  restore=
  if [ "$(mockery_cli_version_exists_without_prefix "$MOCKERY_VERSION")" = "true" ]; then
    restore=$(backup_mockery_cli_without_prefix "$MOCKERY_VERSION")
  elif [ "$(mockery_cli_version_exists_with_prefix "$MOCKERY_VERSION")" = "true" ]; then
    restore=$(backup_mockery_cli_with_prefix "$MOCKERY_VERSION")
  fi
  # Run make test
  $tmake -e DRY_RUN=true mockery-cli > "$TEST_OUTPUT" 2>&1
  # Removing the lines that are not part of the output but are appended by github actions
  mockery_strip_output
  # Checking the output
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-mockery-cli.output"

  if [ -n "$restore"  ]; then
    restore_binary "$restore"
  fi

  echo "OK"
}

Test_make_mockery_cli_installed() {
  printf "Test make mockery-cli but installed -> "
  # Create a files for test
  create_files_test
  # Run enable recipe mockery
  $tmake enable-recipe PACKAGE=dev NAME=mockery > /dev/null
  # Prepare the test
  restore=
  if [ "$(mockery_cli_version_exists_without_prefix "$MOCKERY_VERSION")" = "true" ]; then
    restore=$(backup_mockery_cli_without_prefix "$MOCKERY_VERSION")
  elif [ "$(mockery_cli_version_exists_with_prefix "$MOCKERY_VERSION")" = "true" ]; then
    restore=$(backup_mockery_cli_with_prefix "$MOCKERY_VERSION")
  fi
  $tmake mockery-cli > /dev/null 2>&1
  # Run make test (try to install the cli but it is already installed)
  $tmake mockery-cli > "$TEST_OUTPUT"
  # Removing the lines that are not part of the output but are appended by github actions
  mockery_strip_output
  # Checking the output
  check_empty_output "$TEST_OUTPUT"

  if [ -n "$restore"  ]; then
    restore_binary "$restore"
  fi

  echo "OK"
}