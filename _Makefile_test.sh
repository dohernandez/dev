#!/bin/bash

TESTDATA_PATH="testdata"
TEST_OUTPUT="test.out"
MAKEFILE_FILE=_Makefile

# region Test make plugin bool64/dev
printf "Test make plugin bool64/dev -> "
# Creating a Makefile.test file for test
cat "$MAKEFILE_FILE"> Makefile.test
# Running command to test
make -f Makefile.test -e MAKEFILE_FILE=Makefile.test > "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-bool64-dev.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make plugin bool64/dev


# region Test make search-recipes with plugin bool64/dev
printf "Test make search-recipes with plugin bool64/dev -> "
# Creating a Makefile.test file for test
cat "$MAKEFILE_FILE"> Makefile.test
# Running command to test
make -f Makefile.test -e MAKEFILE_FILE=Makefile.test search-recipes > "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-search-recipes-bool64-dev.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make search-recipes with plugin bool64/dev


# region Test make list-recipes with plugin bool64/dev
printf "Test make list-recipes with plugin bool64/dev -> "
# Creating a Makefile.test file for test
cat "$MAKEFILE_FILE"> Makefile.test
# Running command to test
make -f Makefile.test -e MAKEFILE_FILE=Makefile.test list-recipes > "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-list-recipes-bool64-dev.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make list-recipes with plugin bool64/dev


# region Test make enable-recipe PLUGIN=bool64/dev NAME=lint with plugin bool64/dev
printf "Test make enable-recipe PLUGIN=bool64/dev NAME=lint with plugin bool64/dev -> "
# Creating a Makefile.test file for test
cat "$MAKEFILE_FILE"> Makefile.test
# Run make to capture the default output
make -f Makefile.test -e MAKEFILE_FILE=Makefile.test > "$TEST_OUTPUT"
# Running command to test
make -f Makefile.test -e MAKEFILE_FILE=Makefile.test enable-recipe PLUGIN=bool64/dev NAME=lint >> "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
# Run make to capture the output with the recipe enabled
make -f Makefile.test -e MAKEFILE_FILE=Makefile.test >> "$TEST_OUTPUT"
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-enable-recipe-bool64-dev-lint.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make enable-recipe PLUGIN=bool64/dev NAME=lint with plugin bool64/dev


# region Test make disable-recipe PLUGIN=bool64/dev NAME=lint with plugin bool64/dev
printf "Test make disable-recipe PLUGIN=bool64/dev NAME=lint with plugin bool64/dev -> "
# Creating a Makefile.test file for test
cat "$MAKEFILE_FILE"> Makefile.test
# First enable the recipe
make -f Makefile.test -e MAKEFILE_FILE=Makefile.test enable-recipe PLUGIN=bool64/dev NAME=lint > /dev/null
# Run make to capture the output with the recipe enabled
make -f Makefile.test -e MAKEFILE_FILE=Makefile.test > "$TEST_OUTPUT"
# Running command to test
make -f Makefile.test -e MAKEFILE_FILE=Makefile.test disable-recipe PLUGIN=bool64/dev NAME=lint >> "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
# Run make to capture the output with the recipe disabled
make -f Makefile.test -e MAKEFILE_FILE=Makefile.test >> "$TEST_OUTPUT"
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-disable-recipe-bool64-dev-lint.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make disable-recipe PLUGIN=bool64/dev NAME=lint with plugin bool64/dev

# region Test make enable-recipe PLUGIN=dev NAME=check with plugin bool64/dev
## This test is to check if the feature require into a mk. @see makefiles/check.mk
printf "Test make enable-recipe PLUGIN=dev NAME=check with plugin bool64/dev -> "
# Creating a Makefile.test file for test
cat "$MAKEFILE_FILE"> Makefile.test
# Run make to capture the default output
make -f Makefile.test -e MAKEFILE_FILE=Makefile.test > "$TEST_OUTPUT"
# Running command to test
make -f Makefile.test -e MAKEFILE_FILE=Makefile.test enable-recipe PLUGIN=dev NAME=check >> "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
# Run make to capture the output with the recipe enabled
make -f Makefile.test -e MAKEFILE_FILE=Makefile.test >> "$TEST_OUTPUT"
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-enable-recipe-bool64-dev-check.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make enable-recipe PLUGIN=dev NAME=check with plugin bool64/dev
