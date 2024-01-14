#!/bin/bash

[ -z "$tmake" ] && tmake="make"
OUTPUT_PATH="$ROOT_PATH/makefiles/testdata/output/check"

Test_make_check_local_plugin() {
  printf "Test make check local plugin -> "
  # Create a files for test
  create_files_test
  # Running command to test
  (echo "local"; echo "makefiles"; echo "") | $tmake install-plugin >/dev/null
  if [ $? -ne 0 ]; then
      echo "make failed"
      exit 1
  fi
  # Run enable recipe check
  $tmake enable-recipe PACKAGE=local NAME=check > /dev/null
  # Run make to capture the output make after to enable the recipe
  $tmake > "$TEST_OUTPUT"
  # Run make check
  $tmake -e UNIT_TEST_PATH=./gotest check >> "$TEST_OUTPUT"
  if [ $? -ne 0 ]; then
      echo "make failed"
      exit 1
  fi
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-check-local.output"

  echo "OK"
}