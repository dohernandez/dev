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
    # Regular expression to match both error message formats and extract "Error 1"
    error_pattern='make(\\[[0-9]+\\])?:.*Error 1'

    cat "$TEST_OUTPUT" | \
        grep -v 'Entering directory' | \
        grep -v 'Leaving directory' | \
        awk -v pattern="$error_pattern" '{ while (match($0, pattern)) { $0 = substr($0, 1, RSTART-1) "Error 1" substr($0, RSTART+RLENGTH); } } 1' \
        > "$TEST_OUTPUT.tmp" && mv "$TEST_OUTPUT.tmp" "$TEST_OUTPUT"
}

check_output() {
#    cat "$1" > "$2"
    # Checking the output
    diff "$1" "$2"
    if [ $? -ne 0 ]; then
        echo "Error in _Makefile_test.sh:${BASH_LINENO[0]}: make output is not the same"
        exit 1
    fi
}

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
  check_output "$TEST_OUTPUT" "$TESTDATA_PATH/make-bool64-dev.output"

  echo "OK"
}

Test_make_search_recipes() {
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
  check_output "$TEST_OUTPUT" "$TESTDATA_PATH/make-search-recipes-bool64-dev.output"

  echo "OK"
}

Test_make_list_recipes() {
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
  check_output "$TEST_OUTPUT" "$TESTDATA_PATH/make-list-recipes-bool64-dev.output"

  echo "OK"
}

Test_make_enable_recipe_package_bool64_dev_name_lint() {
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
  check_output "$TEST_OUTPUT" "$TESTDATA_PATH/make-enable-recipe-bool64-dev-lint.output"

  echo "OK"
}

Test_make_disable_recipe_name_lint() {
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
  check_output "$TEST_OUTPUT" "$TESTDATA_PATH/make-disable-recipe-bool64-dev-lint.output"

  echo "OK"
}

Test_make_enable_recipe_package_dev_name_check() {
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
  check_output "$TEST_OUTPUT" "$TESTDATA_PATH/make-enable-recipe-bool64-dev-check.output"

  echo "OK"
  # TODO: Check
  ## Start extra recipes here.
  #-include $(PLUGIN_BOOL64DEV_MAKEFILES_PATH)/lint.mk
  #-include $(PLUGIN_BOOL64DEV_MAKEFILES_PATH)/test-unit.mk
  #-include $(EXTEND_DEVGO_PATH)/makefiles/test.mk
  #-include $(EXTEND_DEVGO_PATH)/makefiles/check.mk
  ## End extra recipes here.
}

Test_make_search_recipe_after_recipe_enabled() {
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
  check_output "$TEST_OUTPUT" "$TESTDATA_PATH/make-search-recipe-after-recipe-enabled-bool64-dev.output"

  echo "OK"
}

Test_make_enable-recipe_twice_package_dev_name_check() {
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
  check_output "$TEST_OUTPUT" "$TESTDATA_PATH/make-enable-recipe-twice-bool64-dev-check.output"

  echo "OK"
}

Test_make_enable_recipe_not_found_package_dev_name_not_found() {
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
  check_output "$TEST_OUTPUT" "$TESTDATA_PATH/make-enable-recipe-bool64-dev-not-found.output"

  echo "OK"
}

Test_make_disable_recipe_name_lint__not_found__name_check() {
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
  check_output "$TEST_OUTPUT" "$TESTDATA_PATH/make-disable-recipe-lint-not-found-bool64-dev-check.output"

  echo "OK"
}

Test_make_list_recipes_after_recipe_enabled_package_dev_name_check() {
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
  check_output "$TEST_OUTPUT" "$TESTDATA_PATH/make-list-recipes-after-recipe-enabled-bool64-dev-check.output"

  echo "OK"
}

Test_make_install_plugin_local_plugin() {
  printf "Test make install-plugin local plugin -> "
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
  check_output "$TEST_OUTPUT" "$TESTDATA_PATH/make-install-local-plugin-bool64-dev-check.output"

  echo "OK"
}

Test_make_install_plugin_local_without_yml_plugin() {
  printf "Test make install-plugin local without yml plugin -> "
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
  check_output "$TEST_OUTPUT" "$TESTDATA_PATH/make-install-local-plugin-bool64-dev-check.output"

  echo "OK"
}

Test_make_install_plugin_package_plugin() {
  printf "Test make install-plugin package plugin -> "
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
  check_output "$TEST_OUTPUT" "$TESTDATA_PATH/make-install-package-plugin-bool64-dev-check.output"

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
}

Test_make_enable_recipe_package_dev_name_github_actions() {
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
  check_output "$TEST_OUTPUT" "$TESTDATA_PATH/make-enable-recipe-bool64-dev-github-actions.output"

  echo "OK"
}

Test_make_github_actions() {
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
  check_output "$TEST_OUTPUT" "$TESTDATA_PATH/make-github-actions-bool64-dev.output"

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
      echo "The file $file_name exists in the folder $folder_path"
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
}

Test_make_github_actions_release_assets() {
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
  check_output "$TEST_OUTPUT" "$TESTDATA_PATH/make-github-actions-release-assets-bool64-dev.output"

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
}

Test_make_enable_recipe_local_plugin_with_self_require() {
  printf "Test make enable-recipe local plugin with self require -> "
  # Create a files for test
  create_files_test
  (echo "local"; echo "testdata/makefiles"; echo "") | $tmake install-plugin > /dev/null
  if [ $? -ne 0 ]; then
      echo "make failed"
      exit 1
  fi
  # Run make to capture the output make before to enable the recipe
  $tmake > "$TEST_OUTPUT"
  # Run enable recipe check (require self.test)
  $tmake enable-recipe PACKAGE=local NAME=check >> "$TEST_OUTPUT"
  # Run make to capture the output make after to enable the recipe
  $tmake >> "$TEST_OUTPUT"
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_output "$TEST_OUTPUT" "$TESTDATA_PATH/make-enable-recipe-local-bool64-dev-self-require.output"

  echo "OK"
}

Test_make_test_local_plugin() {
  printf "Test make test local plugin -> "
  # Create a files for test
  create_files_test
  (echo "local"; echo "testdata/makefiles"; echo "") | $tmake install-plugin > /dev/null
  if [ $? -ne 0 ]; then
      echo "make failed"
      exit 1
  fi
  # Run enable recipe test
  $tmake enable-recipe PACKAGE=local NAME=test > /dev/null
  # Run make to capture the output make after to enable the recipe
  $tmake > "$TEST_OUTPUT"
  # Run make test
  $tmake -e UNIT_TEST_PATH=./makefiles test >> "$TEST_OUTPUT"
  if [ $? -ne 0 ]; then
      echo "make failed"
      exit 1
  fi
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_output "$TEST_OUTPUT" "$TESTDATA_PATH/make-test-local-bool64-dev.output"

  echo "OK"
}

Test_make_check_local_plugin() {
  printf "Test make check local plugin -> "
  # Create a files for test
  create_files_test
  (echo "local"; echo "testdata/makefiles"; echo "") | $tmake install-plugin > /dev/null
  if [ $? -ne 0 ]; then
      echo "make failed"
      exit 1
  fi
  # Run enable recipe check
  $tmake enable-recipe PACKAGE=local NAME=check > /dev/null
  # Run make to capture the output make after to enable the recipe
  $tmake > "$TEST_OUTPUT"
  # Run make check
  $tmake -e UNIT_TEST_PATH=./makefiles check >> "$TEST_OUTPUT"
  if [ $? -ne 0 ]; then
      echo "make failed"
      exit 1
  fi
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_output "$TEST_OUTPUT" "$TESTDATA_PATH/make-check-local-bool64-dev.output"

  echo "OK"
}

# Get a list of all defined functions
all_functions=$(declare -F | cut -d' ' -f3)

# Filter functions starting with "Test_"
test_functions=$(echo "$all_functions" | grep '^Test_')

# Check if a specific function is provided as an argument
if [ $# -eq 1 ]; then
    target_function=$1
    if echo "$test_functions" | grep -q -w "$target_function"; then
        # If the provided function is a valid test function, run it
        $target_function
        exit
    else
        echo "Invalid function name: $target_function"
        exit 1
    fi
fi

# Iterate over filtered functions and run them
for func in $test_functions; do
    $func
done