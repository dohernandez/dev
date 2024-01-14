#!/bin/bash

[ -z "$tmake" ] && tmake="make"
OUTPUT_PATH="$ROOT_PATH/makefiles/testdata/output/recipe"


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
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-search-recipes.output"

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
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-list-recipes.output"

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
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-enable-recipe-lint.output"

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
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-disable-recipe-lint.output"

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
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-enable-recipe-check.output"

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
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-search-recipe-after-recipe-enabled.output"

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
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-enable-recipe-twice-bool64-dev-check.output"

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
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-enable-recipe-not-found.output"

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
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-disable-recipe-lint-not-found-check.output"

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
  # Running command to test
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
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-list-recipes-after-recipe-enabled-check.output"

  echo "OK"
}

Test_make_install_plugin_local_plugin() {
 printf "Test make install-plugin local plugin -> "
 # Create a files for test
 create_files_test
 # Run make to capture the output search recipes before install the plugin
 $tmake search-recipes > "$TEST_OUTPUT"
 # Running command to test
 (echo "local"; echo "makefiles"; echo "") | $tmake install-plugin >> "$TEST_OUTPUT"
 if [ $? -ne 0 ]; then
     echo "make failed"
     exit 1
 fi
 # Run make to capture the output search recipes after install the plugin
 $tmake search-recipes >> "$TEST_OUTPUT"
 # Removing the lines that are not part of the output but are appended by github actions
 strip_output
 # Checking the output
 check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-install-local-plugin-check.output"

 echo "OK"
}

Test_make_install_plugin_local_without_yml_plugin() {
 printf "Test make install-plugin local without yml plugin -> "
 # Create a files for test
 create_files_test
 # Remove the plugin manifest file
 rm makefile.yml
 # Run make to capture the output search recipes before install the plugin
 $tmake search-recipes > "$TEST_OUTPUT"
 # Running command to test
 (echo "local"; echo "makefiles"; echo "") | $tmake install-plugin >> "$TEST_OUTPUT"
 if [ $? -ne 0 ]; then
     echo "make failed"
     exit 1
 fi
 # Run make to capture the output search recipes after install the plugin
 $tmake search-recipes >> "$TEST_OUTPUT"
 # Removing the lines that are not part of the output but are appended by github actions
 strip_output
 # Checking the output
 check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-install-local-plugin-check.output"

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
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-install-package-plugin-check.output"

  # Checking the noprune.go file
  cat <<EOL | diff - noprune.go
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

Test_make_enable_recipe_local_plugin_with_self_require() {
  printf "Test make enable-recipe local plugin with self require -> "
  # Create a files for test
  create_files_test
  # Running command to test
  (echo "local"; echo "makefiles"; echo "") | $tmake install-plugin > /dev/null 2>&1
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
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-enable-recipe-local-self-require.output"

  echo "OK"
}

Test_make_install_plugin_package_and_local_plugins() {
  printf "Test make install-plugin package and local plugins -> "
  # Create a files for test
  create_files_test
  # Installing package plugin
  (echo "github.com/dohernandez/storage"; echo ""; echo "main.mk") | $tmake install-plugin > "$TEST_OUTPUT" 2>&1
  if [ $? -ne 0 ]; then
      echo "make failed"
      exit 1
  fi
  # Installing local plugin
  (echo "local"; echo "makefiles"; echo "") | $tmake install-plugin >> "$TEST_OUTPUT" 2>&1
  if [ $? -ne 0 ]; then
      echo "make failed"
      exit 1
  fi
  # Run make to capture after two plugin installed output
  $tmake search-recipes >> "$TEST_OUTPUT" 2>&1
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
#  cat "$TEST_OUTPUT" | grep -v "go: -modfile=go.mod.test: file does not have .mod extension" \
#    > "$TEST_OUTPUT.tmp" && mv "$TEST_OUTPUT.tmp" "$TEST_OUTPUT"
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-install-package-local-plugins.output"

  # Checking the noprune.go file
  cat <<EOL | diff - noprune.go
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
