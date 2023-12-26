#!/bin/bash

PWD=$(pwd)

TESTDATA_PATH="$PWD/testdata"
TEST_OUTPUT="$PWD/test.out"
MAKEFILE_FILE="$PWD/testdata/Makefile"
PLUGIN_MANIFEST_FILE="$PWD/testdata/makefile.yml"

# tmake is the base command to run make
# Every timme the command runs, it runs in a new shell with the local env
# avoiding to use the env from the upstream runner
tmake="env -i ENV_PATH=./env_test.out ./testdata/env-run.sh make -f Makefile.test -e MAKEFILE_FILE=Makefile.test -e PLUGIN_MANIFEST_FILE=makefile.yaml.test"

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
# Removing the lines that are not part of the output but are appended by github actions
cat "$TEST_OUTPUT" | grep -v "make: Entering directory '/home/runner/work/dev/dev'" \
  | grep -v "make: Leaving directory '/home/runner/work/dev/dev'" > "$TEST_OUTPUT.tmp" \
  && mv "$TEST_OUTPUT.tmp" "$TEST_OUTPUT"
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
cat "$PLUGIN_MANIFEST_FILE" > makefile.yaml.test
# Running command to test
$tmake search-recipes > "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
# Removing the lines that are not part of the output but are appended by github actions
cat "$TEST_OUTPUT" | grep -v "make: Entering directory '/home/runner/work/dev/dev'" \
  | grep -v "make: Leaving directory '/home/runner/work/dev/dev'" > "$TEST_OUTPUT.tmp" \
  && mv "$TEST_OUTPUT.tmp" "$TEST_OUTPUT"
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
cat "$PLUGIN_MANIFEST_FILE" > makefile.yaml.test
# Running command to test
$tmake list-recipes > "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
# Removing the lines that are not part of the output but are appended by github actions
cat "$TEST_OUTPUT" | grep -v "make: Entering directory '/home/runner/work/dev/dev'" \
  | grep -v "make: Leaving directory '/home/runner/work/dev/dev'" > "$TEST_OUTPUT.tmp" \
  && mv "$TEST_OUTPUT.tmp" "$TEST_OUTPUT"
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-list-recipes-bool64-dev.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make list-recipes with plugin bool64/dev


# region Test make enable-recipe PACKAGE=bool64/dev NAME=lint with plugin bool64/dev
printf "Test make enable-recipe PACKAGE=bool64/dev NAME=lint with plugin bool64/dev -> "
# Creating a Makefile.test file for test
cat "$MAKEFILE_FILE"> Makefile.test
cat "$PLUGIN_MANIFEST_FILE" > makefile.yaml.test
# Run make to capture the default output
$tmake > "$TEST_OUTPUT"
# Running command to test
$tmake enable-recipe PACKAGE=bool64/dev NAME=lint >> "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
# Run make to capture the output with the recipe enabled
$tmake >> "$TEST_OUTPUT"
# Removing the lines that are not part of the output but are appended by github actions
cat "$TEST_OUTPUT" | grep -v "make: Entering directory '/home/runner/work/dev/dev'" \
  | grep -v "make: Leaving directory '/home/runner/work/dev/dev'" > "$TEST_OUTPUT.tmp" \
  && mv "$TEST_OUTPUT.tmp" "$TEST_OUTPUT"
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-enable-recipe-bool64-dev-lint.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make enable-recipe PACKAGE=bool64/dev NAME=lint with plugin bool64/dev


# region Test make disable-recipe NAME=lint with plugin bool64/dev
printf "Test make disable-recipe NAME=lint with plugin bool64/dev -> "
# Creating a Makefile.test file for test
cat "$MAKEFILE_FILE"> Makefile.test
cat "$PLUGIN_MANIFEST_FILE" > makefile.yaml.test
# First enable the recipe
$tmake enable-recipe PACKAGE=bool64/dev NAME=lint > /dev/null
# Run make to capture the output with the recipe enabled
$tmake > "$TEST_OUTPUT"
# Running command to test
$tmake disable-recipe NAME=lint >> "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
# Run make to capture the output with the recipe disabled
$tmake >> "$TEST_OUTPUT"
# Removing the lines that are not part of the output but are appended by github actions
cat "$TEST_OUTPUT" | grep -v "make: Entering directory '/home/runner/work/dev/dev'" \
  | grep -v "make: Leaving directory '/home/runner/work/dev/dev'" > "$TEST_OUTPUT.tmp" \
  && mv "$TEST_OUTPUT.tmp" "$TEST_OUTPUT"
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-disable-recipe-bool64-dev-lint.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make disable-recipe NAME=lint with plugin bool64/dev


# region Test make enable-recipe PACKAGE=dev NAME=check with plugin bool64/dev
## This test is to check if the feature require into a mk. @see makefiles/check.mk
printf "Test make enable-recipe PACKAGE=dev NAME=check with plugin bool64/dev -> "
# Creating a Makefile.test file for test
cat "$MAKEFILE_FILE"> Makefile.test
cat "$PLUGIN_MANIFEST_FILE" > makefile.yaml.test
# Run make to capture the default output
$tmake > "$TEST_OUTPUT"
# Running command to test
$tmake enable-recipe PACKAGE=dev NAME=check >> "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
# Run make to capture the output with the recipe enabled
$tmake >> "$TEST_OUTPUT"
# Removing the lines that are not part of the output but are appended by github actions
cat "$TEST_OUTPUT" | grep -v "make: Entering directory '/home/runner/work/dev/dev'" \
  | grep -v "make: Leaving directory '/home/runner/work/dev/dev'" > "$TEST_OUTPUT.tmp" \
  && mv "$TEST_OUTPUT.tmp" "$TEST_OUTPUT"
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-enable-recipe-bool64-dev-check.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make enable-recipe PACKAGE=dev NAME=check with plugin bool64/dev


# region Test make search-recipe after recipe enabled with plugin bool64/dev
printf "Test make search-recipe after recipe enabled with plugin bool64/dev -> "
# Creating a Makefile.test file for test
cat "$MAKEFILE_FILE"> Makefile.test
cat "$PLUGIN_MANIFEST_FILE" > makefile.yaml.test
# Run make to capture the default output
$tmake search-recipes > "$TEST_OUTPUT"
# Running command to test
$tmake enable-recipe PACKAGE=dev NAME=check >> "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
# Run make to capture the output with the recipe enabled
$tmake search-recipes >> "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
# Removing the lines that are not part of the output but are appended by github actions
cat "$TEST_OUTPUT" | grep -v "make: Entering directory '/home/runner/work/dev/dev'" \
  | grep -v "make: Leaving directory '/home/runner/work/dev/dev'" > "$TEST_OUTPUT.tmp" \
  && mv "$TEST_OUTPUT.tmp" "$TEST_OUTPUT"
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-search-recipe-after-recipe-enabled-bool64-dev.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make search-recipe after recipe enabled with plugin bool64/dev


# region Test make enable-recipe twice PACKAGE=dev NAME=check with plugin bool64/dev
printf "Test make enable-recipe twice PACKAGE=dev NAME=check with plugin bool64/dev -> "
# Creating a Makefile.test file for test
cat "$MAKEFILE_FILE"> Makefile.test
cat "$PLUGIN_MANIFEST_FILE" > makefile.yaml.test
# Run make to capture the default output
$tmake > "$TEST_OUTPUT"
# Running command to enable first time the recipe
$tmake enable-recipe PACKAGE=dev NAME=check >> "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
# Run make to capture the output with the recipe enabled
$tmake >> "$TEST_OUTPUT"
# Running command to test
$tmake enable-recipe PACKAGE=dev NAME=check >> "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
# Run make to capture the output with the recipe enabled twice
$tmake >> "$TEST_OUTPUT"
# Removing the lines that are not part of the output but are appended by github actions
cat "$TEST_OUTPUT" | grep -v "make: Entering directory '/home/runner/work/dev/dev'" \
  | grep -v "make: Leaving directory '/home/runner/work/dev/dev'" > "$TEST_OUTPUT.tmp" \
  && mv "$TEST_OUTPUT.tmp" "$TEST_OUTPUT"
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-enable-recipe-twice-bool64-dev-check.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make enable-recipe twice PACKAGE=dev NAME=check with plugin bool64/dev


# region Test make enable-recipe not found PACKAGE=dev NAME=check with plugin bool64/dev
printf "Test make enable-recipe not found PACKAGE=dev NAME=check with plugin bool64/dev -> "
# Creating a Makefile.test file for test
cat "$MAKEFILE_FILE"> Makefile.test
cat "$PLUGIN_MANIFEST_FILE" > makefile.yaml.test
# Run make to capture the default output
$tmake > "$TEST_OUTPUT"
# Running command to test
$tmake enable-recipe PACKAGE=dev NAME=not-found >> "$TEST_OUTPUT" 2>&1
if [ $? -eq 0 ]; then
    echo "make should fail"
    exit 1
fi
# Run make to capture the output after run the command
$tmake >> "$TEST_OUTPUT"
# Removing the lines that are not part of the output but are appended by github actions
cat "$TEST_OUTPUT" | grep -v "make: Entering directory '/home/runner/work/dev/dev'" \
  | grep -v "make: Leaving directory '/home/runner/work/dev/dev'" \
  | sed -r 's/make: \*\*\* \[[^]]*\: ([^]]*)\] Error 1/make[1]: *** [\1] Error 1/' > "$TEST_OUTPUT.tmp" \
  && mv "$TEST_OUTPUT.tmp" "$TEST_OUTPUT"
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-enable-recipe-not-found-bool64-dev-check.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make enable-recipe not found PACKAGE=dev NAME=check with plugin bool64/dev


# region Test make disable-recipe NAME=lint (not found) NAME=check with plugin bool64/dev
printf "Test make disable-recipe NAME=lint (not found) NAME=check with plugin bool64/dev -> "
# Creating a Makefile.test file for test
cat "$MAKEFILE_FILE"> Makefile.test
cat "$PLUGIN_MANIFEST_FILE" > makefile.yaml.test
# Run make to capture the default output
$tmake > "$TEST_OUTPUT"
# Running command to test
$tmake disable-recipe NAME=lint >> "$TEST_OUTPUT" 2>&1
if [ $? -eq 0 ]; then
    echo "make should fail"
    exit 1
fi
# Run make to capture the output after run the command
$tmake >> "$TEST_OUTPUT"
# Removing the lines that are not part of the output but are appended by github actions
cat "$TEST_OUTPUT" | grep -v "make: Entering directory '/home/runner/work/dev/dev'" \
  | grep -v "make: Leaving directory '/home/runner/work/dev/dev'" \
  | sed -r 's/make: \*\*\* \[[^]]*\: ([^]]*)\] Error 1/make[1]: *** [\1] Error 1/' > "$TEST_OUTPUT.tmp" \
  && mv "$TEST_OUTPUT.tmp" "$TEST_OUTPUT"
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-disable-recipe-lint-not-found-bool64-dev-check.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make disable-recipe NAME=lint (not found) NAME=check with plugin bool64/dev


# region Test make list-recipes after recipe enabled PACKAGE=dev NAME=check with plugin bool64/dev
printf "Test make list-recipes after recipe enabled PACKAGE=dev NAME=check with plugin bool64/dev -> "
# Creating a Makefile.test file for test
cat "$MAKEFILE_FILE"> Makefile.test
cat "$PLUGIN_MANIFEST_FILE" > makefile.yaml.test
# Run make to capture the default output
$tmake > "$TEST_OUTPUT"
# Run make to capture the output list recipes before enable the recipe
$tmake list-recipes >> "$TEST_OUTPUT"
# Running command to enable first time the recipe
$tmake enable-recipe PACKAGE=dev NAME=check >> "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
# Run make to capture the output with the recipe enabled
$tmake >> "$TEST_OUTPUT"
# Running command to test
$tmake list-recipes >> "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
# Removing the lines that are not part of the output but are appended by github actions
cat "$TEST_OUTPUT" | grep -v "make: Entering directory '/home/runner/work/dev/dev'" \
  | grep -v "make: Leaving directory '/home/runner/work/dev/dev'" > "$TEST_OUTPUT.tmp" \
  && mv "$TEST_OUTPUT.tmp" "$TEST_OUTPUT"
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-list-recipes-after-recipe-enabled-bool64-dev-check.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make list-recipes after recipe enabled PACKAGE=dev NAME=check with plugin bool64/dev

# region Test make install local plugin with plugin bool64/dev
printf "Test make install local plugin with plugin bool64/dev -> "
# Creating a Makefile.test file for test
cat "$MAKEFILE_FILE"> Makefile.test
cat "$PLUGIN_MANIFEST_FILE" > makefile.yaml.test
# Run make to capture the output search recipes before install the plugin
$tmake search-recipes > "$TEST_OUTPUT"
# Running command to test
(echo "local"; echo "testdata/makefiles"; echo "") | $tmake install-plugin >> "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
# Run make to capture the output search recipes after install the plugin
$tmake search-recipes >> "$TEST_OUTPUT"
# Removing the lines that are not part of the output but are appended by github actions
cat "$TEST_OUTPUT" | grep -v "make: Entering directory '/home/runner/work/dev/dev'" \
  | grep -v "make: Leaving directory '/home/runner/work/dev/dev'" > "$TEST_OUTPUT.tmp" \
  && mv "$TEST_OUTPUT.tmp" "$TEST_OUTPUT"
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-install-local-plugin-bool64-dev-check.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make install local plugin with plugin bool64/dev
