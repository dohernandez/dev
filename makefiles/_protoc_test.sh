#!/bin/bash

[ -z "$tmake" ] && tmake="make"
OUTPUT_PATH="$ROOT_PATH/makefiles/testdata/output/protoc"

PROTOBUF_VERSION="25.2"
PROTOC_GEN_GO_VERSION="1.28.0"
PROTOC_GEN_GO_GRPC_VERSION="1.3.0"

Test_make_recipe_enable_protoc() {
  printf "Test make recipe-enable protoc -> "
  # Create a files for test
  create_files_test
  # Run enable recipe protoc
  $tmake enable-recipe PACKAGE=dev NAME=protoc > "$TEST_OUTPUT"
  # Run make test
  $tmake >> "$TEST_OUTPUT"
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-recipe-enable-protoc.output"

  echo "OK"
}

protoc_cli_version_exists_without_suffix() {
  version="$1"

  # checking if protoc is available without the version prefix.
  if command -v protoc >/dev/null; then
    version_installed="$(protoc --version | cut -d' ' -f2)"

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

backup_protoc_cli_without_suffix() {
  version="$1"

  path=$(which protoc)

  mv "$path" "$path".bak

  echo "$path".bak
}

protoc_cli_version_exists_with_suffix() {
  version="$1"

  # checking if protoc is available with the version prefix.
  if command -v protoc-"v$version" >/dev/null; then
    echo "true"
    exit 0
  fi

  echo "false"
}

backup_protoc_cli_with_suffix() {
  version="$1"

  path=$(which protoc-"v$version")

  mv "$path" "$path".bak

  echo "$path".bak
}

restore_binary() {
  path="$1"

  mv "$path" "${path%.bak}"
}

Test_make_protoc_cli() {
  printf "Test make protoc-cli -> "
  # Create a files for test
  create_files_test
  rm -rf "$HOME"/protobuf/"v$PROTOBUF_VERSION"
  # Run enable recipe protoc
  $tmake enable-recipe PACKAGE=dev NAME=protoc > /dev/null
  # Prepare the test
  restore=()
  if [ "$(protoc_cli_version_exists_without_suffix "$PROTOBUF_VERSION")" = "true" ]; then
    restore+=("$(backup_protoc_cli_without_suffix "$PROTOBUF_VERSION")")
  fi
  if [ "$(protoc_cli_version_exists_with_suffix "$PROTOBUF_VERSION")" = "true" ]; then
    restore+=("$(backup_protoc_cli_with_suffix "$PROTOBUF_VERSION")")
  fi
  # Run make test
  $tmake -e DRY_RUN=true protoc-cli > "$TEST_OUTPUT" 2>&1
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-protoc-cli.output"

  if [ -n "$restore"  ]; then
    restore_binary "$restore"
  fi

  echo "OK"
}

Test_make_protoc_cli_installed() {
  printf "Test make protoc-cli but installed -> "
  # Create a files for test
  create_files_test
  rm -rf "$HOME"/protobuf/"v$PROTOBUF_VERSION"
  # Run enable recipe protoc
  $tmake enable-recipe PACKAGE=dev NAME=protoc > /dev/null
  # Prepare the test
  restore=()
  if [ "$(protoc_cli_version_exists_without_suffix "$PROTOBUF_VERSION")" = "true" ]; then
    restore+=("$(backup_protoc_cli_without_suffix "$PROTOBUF_VERSION")")
  fi
  if [ "$(protoc_cli_version_exists_with_suffix "$PROTOBUF_VERSION")" = "true" ]; then
    restore+=("$(backup_protoc_cli_with_suffix "$PROTOBUF_VERSION")")
  fi
  $tmake protoc-cli > /dev/null 2>&1
  # Run make test (try to install the cli but it is already installed)
  $tmake protoc-cli > "$TEST_OUTPUT"
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_empty_output "$TEST_OUTPUT"

  if [ -n "$restore"  ]; then
    echo "restore_binary $restore"
    restore_binary "$restore"
  fi

  echo "OK"
}

protoc_gen_cli_version_exists_without_suffix() {
  version="$1"

  # checking if protoc is available without the version prefix.
  if command -v protoc-gen-go >/dev/null; then
    version_installed="$(protoc-gen-go --version | cut -d' ' -f2)"

    if [ "${version_installed}" = "v${version}" ]; then \
      echo "true"
      exit 0
    fi
  fi

  echo "false"
}

backup_protoc_gen_cli_without_suffix() {
  version="$1"

  path=$(which protoc-gen-go)

  mv "$path" "$path".bak

  echo "$path".bak
}

protoc_gen_cli_version_exists_with_suffix() {
  version="$1"

  # checking if protoc is available with the version prefix.
  if command -v protoc-gen-go-"v$version" >/dev/null; then
    echo "true"
    exit 0
  fi

  echo "false"
}

backup_protoc_gen_cli_with_suffix() {
  version="$1"

  path=$(which protoc-gen-go-"v$version")

  mv "$path" "$path".bak

  echo "$path".bak
}

Test_make_protoc_gen_cli() {
  printf "Test make protoc-gen-cli -> "
  # Create a files for test
  create_files_test
  # Run enable recipe protoc
  $tmake enable-recipe PACKAGE=dev NAME=protoc > /dev/null
  # Prepare the test
  restore=()
  if [ "$(protoc_gen_cli_version_exists_without_suffix "$PROTOC_GEN_GO_VERSION")" = "true" ]; then
    restore+=("$(backup_protoc_gen_cli_without_suffix "$PROTOC_GEN_GO_VERSION")")
  fi
  if [ "$(protoc_gen_cli_version_exists_with_suffix "$PROTOC_GEN_GO_VERSION")" = "true" ]; then
    restore+=("$(backup_protoc_gen_cli_with_suffix "$PROTOC_GEN_GO_VERSION")")
  fi
  # Run make test
  $tmake -e DRY_RUN=true protoc-gen-cli > "$TEST_OUTPUT" 2>&1
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-protoc-gen-cli.output"

  for path in "${restore[@]}"; do
    restore_binary "$path"
  done

  echo "OK"
}

Test_make_protoc_gen_cli_installed() {
  printf "Test make protoc-gen-cli but installed -> "
  # Create a files for test
  create_files_test
  # Run enable recipe protoc
  $tmake enable-recipe PACKAGE=dev NAME=protoc > /dev/null
  # Prepare the test
  restore=()
  if [ "$(protoc_gen_cli_version_exists_without_suffix "$PROTOC_GEN_GO_VERSION")" = "true" ]; then
    restore+=("$(backup_protoc_gen_cli_without_suffix "$PROTOC_GEN_GO_VERSION")")
  fi
  if [ "$(protoc_gen_cli_version_exists_with_suffix "$PROTOC_GEN_GO_VERSION")" = "true" ]; then
    restore+=("$(backup_protoc_gen_cli_with_suffix "$PROTOC_GEN_GO_VERSION")")
  fi
  $tmake protoc-gen-cli > /dev/null 2>&1
  # Run make test (try to install the cli but it is already installed)
  $tmake protoc-gen-cli > "$TEST_OUTPUT"
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_empty_output "$TEST_OUTPUT"

  for path in "${restore[@]}"; do
    restore_binary "$path"
  done

  echo "OK"
}

protoc_gen_grpc_cli_version_exists_without_suffix() {
  version="$1"

  # checking if protoc is available without the version prefix.
  if command -v protoc-gen-go-grpc >/dev/null; then
    version_installed="$(protoc-gen-go-grpc --version | cut -d' ' -f2)"

    if [ "${version_installed}" = "${version}" ]; then \
      echo "true"
      exit 0
    fi
  fi

  echo "false"
}

backup_protoc_gen_grpc_cli_without_suffix() {
  version="$1"

  path=$(which protoc-gen-go-grpc)

  mv "$path" "$path".bak

  echo "$path".bak
}

protoc_gen_grpc_cli_version_exists_with_suffix() {
  version="$1"

  # checking if protoc is available with the version prefix.
  if command -v protoc-gen-go-grpc-"v$version" >/dev/null; then
    echo "true"
    exit 0
  fi

  echo "false"
}

backup_protoc_gen_grpc_cli_with_suffix() {
  version="$1"

  path=$(which protoc-gen-go-grpc-"v$version")

  mv "$path" "$path".bak

  echo "$path".bak
}

Test_make_protoc_gen_grpc_cli() {
  printf "Test make protoc-gen-grpc-cli -> "
  # Create a files for test
  create_files_test
  # Run enable recipe protoc
  $tmake enable-recipe PACKAGE=dev NAME=protoc > /dev/null
  # Prepare the test
  restore=()
  if [ "$(protoc_gen_grpc_cli_version_exists_without_suffix "$PROTOC_GEN_GO_GRPC_VERSION")" = "true" ]; then
    restore+=("$(backup_protoc_gen_grpc_cli_without_suffix "$PROTOC_GEN_GO_GRPC_VERSION")")
  fi
  if [ "$(protoc_gen_grpc_cli_version_exists_with_suffix "$PROTOC_GEN_GO_GRPC_VERSION")" = "true" ]; then
    restore+=("$(backup_protoc_gen_grpc_cli_with_suffix "$PROTOC_GEN_GO_GRPC_VERSION")")
  fi
  # Run make test
  $tmake -e DRY_RUN=true protoc-gen-grpc-cli > "$TEST_OUTPUT" 2>&1
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-protoc-gen-grpc-cli.output"

  for path in "${restore[@]}"; do
    restore_binary "$path"
  done

  echo "OK"
}

Test_make_protoc_gen_grpc_cli_installed() {
  printf "Test make protoc-gen-grpc-cli but installed -> "
  # Create a files for test
  create_files_test
  # Run enable recipe protoc
  $tmake enable-recipe PACKAGE=dev NAME=protoc > /dev/null
  # Prepare the test
  restore=()
  if [ "$(protoc_gen_grpc_cli_version_exists_without_suffix "$PROTOC_GEN_GO_GRPC_VERSION")" = "true" ]; then
    restore+=("$(backup_protoc_gen_grpc_cli_without_suffix "$PROTOC_GEN_GO_GRPC_VERSION")")
  fi
  if [ "$(protoc_gen_grpc_cli_version_exists_with_suffix "$PROTOC_GEN_GO_GRPC_VERSION")" = "true" ]; then
    restore+=("$(backup_protoc_gen_grpc_cli_with_suffix "$PROTOC_GEN_GO_GRPC_VERSION")")
  fi
  $tmake protoc-gen-grpc-cli > /dev/null 2>&1
  # Run make test (try to install the cli but it is already installed)
  $tmake protoc-gen-grpc-cli > "$TEST_OUTPUT"
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_empty_output "$TEST_OUTPUT"

  for path in "${restore[@]}"; do
    restore_binary "$path"
  done

  echo "OK"
}