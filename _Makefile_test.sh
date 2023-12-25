#!/bin/bash

PWD=$(pwd)

TESTDATA_PATH="$PWD/testdata"
TEST_OUTPUT="$PWD/test.out"
MAKEFILE_FILE="$PWD/testdata/Makefile"
PLUGIN_MANIFEST_FILE="$PWD/testdata/makefile.yml"

tmake="make -f Makefile.test -e MAKEFILE_FILE=Makefile.test -e PLUGIN_MANIFEST_FILE=makefile.yaml.test"

# region Test make plugin bool64/dev
printf "Test make plugin bool64/dev -> "
# Creating a Makefile.test file for test
cat "$MAKEFILE_FILE"> Makefile.test
cat "$PLUGIN_MANIFEST_FILE" > makefile.yaml.test
# Running command to test
$tmake > "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
echo "start cat output"
cat "$TEST_OUTPUT" | grep -v "make\[1\]: Entering directory '/home/runner/work/dev/dev'" \
  | grep -v "make\[1\]: Leaving directory '/home/runner/work/dev/dev'"

echo "end cat output"
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-bool64-dev.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make plugin bool64/dev
