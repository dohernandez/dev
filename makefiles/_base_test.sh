#!/bin/bash

[ -z "$tmake" ] && tmake="make"
OUTPUT_PATH="makefiles/testdata/output/base"

Test_make() {
  printf "Test make -> "
  # Create a files for test
  create_files_test
  # Running command to test
  $tmake > "$TEST_OUTPUT"
  if [ $? -ne 0 ]; then
      echo "make failed"
      exit 1
  fi
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make.output"

  echo "OK"
}
