#!/bin/bash

for p in $(env | grep '^PLUGIN' | cut -d= -f1); do unset $p; done

PWD=$(pwd)

TESTDATA_PATH="$PWD/testdata"
TEST_OUTPUT="$PWD/test.out"
MAKEFILE_FILE="$PWD/testdata/Makefile"
PLUGIN_MANIFEST_FILE="$PWD/testdata/makefile.yml"
NOPRUNE_FILE="$PWD/testdata/noprune.go"
GOMOD_FILE="$PWD/testdata/go.mod"

# tmake is the base command to run make
# Every timme the command runs, it runs in a new shell with the local env
# avoiding to use the env from the upstream runner
tmake="make -f Makefile.test
      -e MAKEFILE_FILE=Makefile.test
      -e PLUGIN_MANIFEST_FILE=makefile.yaml.test
      -e NOPRUNE_FILE=noprune.go.test
      -e GOMOD_FILE=$GOMOD_FILE
      "

# create_files_test create a files for test
create_files_test() {
    # Creating files for test
    cat "$MAKEFILE_FILE"> Makefile.test
    cat "$PLUGIN_MANIFEST_FILE" > makefile.yaml.test
    cat "$NOPRUNE_FILE" > noprune.go.test
}

strip_output() {
    # Removing the lines that are not part of the output but are appended by github actions
    cat "$TEST_OUTPUT" | grep -v "make\[1\]: Entering directory '/home/runner/work/dev/dev'" \
      | grep -v "make\[1\]: Leaving directory '/home/runner/work/dev/dev'" \
      | sed -r 's/make\[1\]: \*\*\* \[[^]]*\: ([^]]*)\] Error 1/make[1]: *** [\1] Error 1/' > "$TEST_OUTPUT.tmp" \
      && mv "$TEST_OUTPUT.tmp" "$TEST_OUTPUT"
}

# region Test make
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
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-bool64-dev.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make


# region Test make search-recipes
printf "Test make search-recipes -> "
# Create a files for test
create_files_test
# Running command to test
$tmake search-recipes > "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
# Removing the lines that are not part of the output but are appended by github actions
strip_output
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-search-recipes-bool64-dev.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make search-recipes


# region Test make list-recipes
printf "Test make list-recipes -> "
# Create a files for test
create_files_test
# Running command to test
$tmake list-recipes > "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
# Removing the lines that are not part of the output but are appended by github actions
strip_output
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-list-recipes-bool64-dev.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make list-recipes


# region Test make enable-recipe PACKAGE=bool64/dev NAME=lint
printf "Test make enable-recipe PACKAGE=bool64/dev NAME=lint -> "
# Create a files for test
create_files_test
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
strip_output
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-enable-recipe-bool64-dev-lint.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make enable-recipe PACKAGE=bool64/dev NAME=lint


# region Test make disable-recipe NAME=lint
printf "Test make disable-recipe NAME=lint -> "
# Create a files for test
create_files_test
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
strip_output
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-disable-recipe-bool64-dev-lint.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make disable-recipe NAME=lint


# region Test make enable-recipe PACKAGE=dev NAME=check
## This test is to check if the feature require into a mk. @see makefiles/check.mk
printf "Test make enable-recipe PACKAGE=dev NAME=check -> "
# Create a files for test
create_files_test
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
strip_output
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-enable-recipe-bool64-dev-check.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make enable-recipe PACKAGE=dev NAME=check


# region Test make search-recipe after recipe enabled
printf "Test make search-recipe after recipe enabled -> "
# Create a files for test
create_files_test
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
strip_output
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-search-recipe-after-recipe-enabled-bool64-dev.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make search-recipe after recipe enabled


# region Test make enable-recipe twice PACKAGE=dev NAME=check
printf "Test make enable-recipe twice PACKAGE=dev NAME=check -> "
# Create a files for test
create_files_test
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
strip_output
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-enable-recipe-twice-bool64-dev-check.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make enable-recipe twice PACKAGE=dev NAME=check


# region Test make enable-recipe not found PACKAGE=dev NAME=not-found
printf "Test make enable-recipe not found PACKAGE=dev NAME=not-found -> "
# Create a files for test
create_files_test
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
strip_output
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-enable-recipe-bool64-dev-not-found.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make enable-recipe not found PACKAGE=dev NAME=not-found


# region Test make disable-recipe NAME=lint (not found) NAME=check
printf "Test make disable-recipe NAME=lint (not found) NAME=check -> "
# Create a files for test
create_files_test
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
strip_output
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-disable-recipe-lint-not-found-bool64-dev-check.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make disable-recipe NAME=lint (not found) NAME=check


# region Test make list-recipes after recipe enabled PACKAGE=dev NAME=check
printf "Test make list-recipes after recipe enabled PACKAGE=dev NAME=check -> "
# Create a files for test
create_files_test
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
strip_output
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-list-recipes-after-recipe-enabled-bool64-dev-check.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make list-recipes after recipe enabled PACKAGE=dev NAME=check


# region Test make install local plugin
printf "Test make install local plugin -> "
# Create a files for test
create_files_test
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
strip_output
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-install-local-plugin-bool64-dev-check.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make install local plugin


# region Test make install local without yml plugin
printf "Test make install local without yml plugin -> "
# Creating a Makefile.test file for test
cat "$MAKEFILE_FILE"> Makefile.test
rm makefile.yaml.test
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
strip_output
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-install-local-plugin-bool64-dev-check.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make install local without yml plugin


# region Test make install package plugin
printf "Test make install package plugin -> "
# Create a files for test
create_files_test
# Running command to test
(echo "github.com/dohernandez/storage"; echo "") | $tmake install-plugin > "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
# Removing the lines that are not part of the output but are appended by github actions
strip_output
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-install-package-plugin-bool64-dev-check.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
# Checking the noprune.go file
cat <<EOL | diff - noprune.go.test
//go:build never
// +build never

package noprune

import (
	_ "github.com/bool64/dev" // Include CI/Dev scripts to project.
	_ "github.com/dohernandez/storage"
)
EOL
if [ $? -ne 0 ]; then
    echo "noprune.go file is not the same"
    exit 1
fi
echo "OK"
# endregion Test make install package plugin

# region Test make enable-recipe PACKAGE=dev NAME=github-actions
printf "Test make enable-recipe PACKAGE=dev NAME=github-actions -> "
# Create a files for test
create_files_test
# Run make to capture the default output
$tmake > "$TEST_OUTPUT"
# Running command to test
$tmake enable-recipe PACKAGE=dev NAME=github-actions >> "$TEST_OUTPUT" 2>&1
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
strip_output
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-enable-recipe-bool64-dev-github-actions.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "OK"
# endregion Test make enable-recipe PACKAGE=dev NAME=github-actions


# region Test make github-actions
printf "Test make github-actions -> "
rm -rf "$TESTDATA_PATH/.github"
# Create a files for test
create_files_test
# Run enable recipe github-actions
$tmake enable-recipe PACKAGE=dev NAME=github-actions > /dev/null
# Run make to capture the output with the recipe enabled
$tmake > "$TEST_OUTPUT"
# Run make to capture the output with the recipe enabled
$tmake -e GITHUB_PATH=testdata/.github -e GITHUB_PATH_IGNORE=true github-actions >> "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
# Removing the lines that are not part of the output but are appended by github actions
strip_output
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-github-actions-bool64-dev.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
diff "$TESTDATA_PATH/.github/workflows/check.yml" "$PWD/templates/github/workflows/check.yml"
if [ $? -ne 0 ]; then
    echo "check.yml file is not the same"
    exit 1
fi
diff "$TESTDATA_PATH/.github/workflows/cloc.yml" "$PWD/templates/github/workflows/cloc.yml"
if [ $? -ne 0 ]; then
    echo "cloc.yml file is not the same"
    exit 1
fi
diff "$TESTDATA_PATH/.github/workflows/golangci-lint.yml" "$PWD/templates/github/workflows/golangci-lint.yml"
if [ $? -ne 0 ]; then
    echo "golangci-lint.yml file is not the same"
    exit 1
fi
diff "$TESTDATA_PATH/.github/workflows/release.yml" "$PWD/templates/github/workflows/release.yml"
if [ $? -ne 0 ]; then
    echo "release.yml file is not the same"
    exit 1
fi
diff "$TESTDATA_PATH/.github/workflows/test-unit.yml" "$PWD/templates/github/workflows/test-unit.yml"
if [ $? -ne 0 ]; then
    echo "test-unit.yml file is not the same"
    exit 1
fi
if [ -e "$TESTDATA_PATH/.github/workflows/release-assets.yml" ]; then
    echo "The file $file_name exists in the folder $folder_path."
fi
diff "$TESTDATA_PATH/.github/actions/check-branch/action.yml" "$PWD/templates/github/actions/check-branch/action.yml"
if [ $? -ne 0 ]; then
    echo "action.yml file is not the same"
    exit 1
fi
diff "$TESTDATA_PATH/.github/actions/check-branch/check-branch.sh" "$PWD/templates/github/actions/check-branch/check-branch.sh"
if [ $? -ne 0 ]; then
    echo "check-branch.sh file is not the same"
    exit 1
fi
echo "OK"
# endregion Test make github-actions

# region Test make github-actions-release-assets
printf "Test make github-actions-release-assets -> "
rm -rf "$TESTDATA_PATH/.github"
# Create a files for test
create_files_test
# Run enable recipe github-actions
$tmake enable-recipe PACKAGE=dev NAME=github-actions > /dev/null
# Run make to capture the output with the recipe enabled
$tmake > "$TEST_OUTPUT"
# Run make to capture the output with the recipe enabled
$tmake -e GITHUB_PATH=testdata/.github -e GITHUB_PATH_IGNORE=true github-actions-release-assets >> "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
# Removing the lines that are not part of the output but are appended by github actions
strip_output
# Checking the output
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-github-actions-release-assets-bool64-dev.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
diff "$TESTDATA_PATH/.github/workflows/check.yml" "$PWD/templates/github/workflows/check.yml"
if [ $? -ne 0 ]; then
    echo "check.yml file is not the same"
    exit 1
fi
diff "$TESTDATA_PATH/.github/workflows/cloc.yml" "$PWD/templates/github/workflows/cloc.yml"
if [ $? -ne 0 ]; then
    echo "cloc.yml file is not the same"
    exit 1
fi
diff "$TESTDATA_PATH/.github/workflows/golangci-lint.yml" "$PWD/templates/github/workflows/golangci-lint.yml"
if [ $? -ne 0 ]; then
    echo "golangci-lint.yml file is not the same"
    exit 1
fi
diff "$TESTDATA_PATH/.github/workflows/release.yml" "$PWD/templates/github/workflows/release.yml"
if [ $? -ne 0 ]; then
    echo "release.yml file is not the same"
    exit 1
fi
diff "$TESTDATA_PATH/.github/workflows/test-unit.yml" "$PWD/templates/github/workflows/test-unit.yml"
if [ $? -ne 0 ]; then
    echo "test-unit.yml file is not the same"
    exit 1
fi
diff "$TESTDATA_PATH/.github/workflows/release-assets.yml" "$PWD/templates/github/workflows/release-assets.yml"
if [ $? -ne 0 ]; then
    echo "release-assets.yml file is not the same"
    exit 1
fi
diff "$TESTDATA_PATH/.github/actions/check-branch/action.yml" "$PWD/templates/github/actions/check-branch/action.yml"
if [ $? -ne 0 ]; then
    echo "action.yml file is not the same"
    exit 1
fi
diff "$TESTDATA_PATH/.github/actions/check-branch/check-branch.sh" "$PWD/templates/github/actions/check-branch/check-branch.sh"
if [ $? -ne 0 ]; then
    echo "check-branch.sh file is not the same"
    exit 1
fi
echo "OK"
# endregion Test make github-actions-release-assets

