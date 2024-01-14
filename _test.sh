#!/bin/bash

# Export the environment variables
# Read key-value pairs from the ENV_VARS variable and export them as environment variables
while IFS= read -r line || [ -n "$line" ]; do
  export "$line"
done <<< "$ENV_VARS"

[ -z "$TEST_PATH" ] && TEST_PATH="."

PWD=$(pwd)

TESTDATA_PATH="$PWD/testdata"
MAKEFILE_FILE="$PWD/testdata/Makefile"
PLUGIN_MANIFEST_FILE="$PWD/testdata/makefile.yml"
NOPRUNE_FILE="$PWD/testdata/noprune.go"
GOMOD_FILE="$PWD/testdata/go.mod"

cat "$PWD/makefiles/base.mk" > "$MAKEFILE_FILE"

TESTDATA_ENV_PATH="$TESTDATA_PATH/testenv"
TEST_OUTPUT="$TESTDATA_ENV_PATH/test.out"

# tmake is the base command to run make
# Every timme the command runs, it runs in a new shell with the local env
# avoiding to use the env from the upstream runner
tmake="make"

# create_files_test create a files for test
create_files_test() {
    # Creating files for test
    cat "$MAKEFILE_FILE"> "$TESTDATA_ENV_PATH/Makefile"
    cat "$PLUGIN_MANIFEST_FILE" > "$TESTDATA_ENV_PATH/makefile.yml"
    cat "$NOPRUNE_FILE" > "$TESTDATA_ENV_PATH/noprune.go"
    cat "$GOMOD_FILE" > "$TESTDATA_ENV_PATH/go.mod"
}

strip_output() {
    # Regular expression to match both error message formats and extract "Error 1"
    error_pattern='make(\\[[0-9]+\\])?:.*Error 1'

    cat "$TEST_OUTPUT" | \
        grep -v 'Entering directory' | \
        grep -v 'Leaving directory' | \
        awk -v pattern="$error_pattern" '{ while (match($0, pattern)) { $0 = substr($0, 1, RSTART-1) "Error 1" substr($0, RSTART+RLENGTH); } } 1' \
        > "$TEST_OUTPUT.tmp" && mv "$TEST_OUTPUT.tmp" "$TEST_OUTPUT"
}

TEST_FILE=

check_output() {
#    cat "$1" > "$2"
    # Checking the output
    diff "$1" "$2"
    if [ $? -ne 0 ]; then
      if [ -n "$TEST_FILE" ]; then
        echo "Error in $TEST_FILE:${BASH_LINENO[0]}: make output is not the same"
      fi
      exit 1
    fi
}

check_empty_output() {
    # Checking the output
    content=$(cat "$1")
    if [ -n "$content" ]; then
      echo "Error in $TEST_FILE:${BASH_LINENO[0]}: make output is not empty"
      exit 1
    fi
}

# Use find to search for files matching the pattern
test_files=$(find "$TEST_PATH" -type d -name vendor -prune -o -type f -name "_*_test.sh" -not -path "./$0" -print)

# Record the start time
start_time=$(date +%s)

for test_file in $test_files; do
  print_output=false
  # Check if a specific function is provided as an argument
  if [ $# -eq 1 ]; then
    # Find if file:func, split
      check_file=(${1//:/ })

    if [ "$check_file" != "$test_file" ]; then
      continue
    fi

    print_output=true
    test_file=(${1//:/ })
  fi

  # Extract function declarations using grep
  functions=$(grep -Eo '\bfunction[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(|[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(' "$test_file" | tr -d '({)')

  # Source the file to make functions available
  TEST_FILE="$test_file"

  # Filter functions starting with "Test_"
  test_functions=$(echo "$functions" | grep '^Test_')

  printf "$test_file -> "

  if [[ ${#test_functions[@]} -eq 0 ]] || [[ ${#test_functions[@]} -eq 1 && -z ${test_functions[0]} ]]; then
      echo "[no test functions]"

      continue
  fi

  if [ -n "${test_file[1]}" ]; then
    test_functions=(${test_file[1]})
  fi

  if [ "$print_output" = true ]; then
    echo ""
  fi

  source "$test_file"

  start_time_file=$(date +%s.%N)

  # Execute each function
  for func in $test_functions; do
    output=$(cd "$TESTDATA_ENV_PATH" && eval "$func")
    if [ $? -ne 0 ]; then
      if [ "$print_output" = false ]; then
        echo ""
      fi
      echo "$output"
      exit 1
    fi

    if [ "$print_output" = true ]; then
      echo "$output"
    fi
  done

  # Record the end time
  end_time_file=$(date +%s.%N)

  # Calculate the elapsed time with two decimal places
  elapsed_time=$(echo "$end_time_file - $start_time_file" | bc -l | xargs printf "%.2f\n")

  printf "${elapsed_time}s "

  echo "OK"
done

# Record the end time
end_time=$(date +%s.%N)

# Calculate the elapsed time with two decimal places
elapsed_time=$(echo "$end_time - $start_time" | bc -l | xargs printf "%.2f\n")

echo "[OK] ${elapsed_time}s"