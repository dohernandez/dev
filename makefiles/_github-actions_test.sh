#!/bin/bash

[ -z "$tmake" ] && tmake="make"
OUTPUT_PATH="$ROOT_PATH/makefiles/testdata/output/github-actions"

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
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-enable-recipe-github-actions.output"

  echo "OK"
}

Test_make_github_actions_base() {
  printf "Test make github-actions-base -> "
  rm -rf "$TESTDATA_ENV_PATH/.github"
  # Create a files for test
  create_files_test
  # Run enable recipe github-actions
  $tmake enable-recipe PACKAGE=dev NAME=github-actions > /dev/null
  # Run make to capture the output with the recipe enabled
  $tmake > "$TEST_OUTPUT"
  # Running command to test
  $tmake -e GITHUB_PATH=.github -e GITHUB_PATH_IGNORE=true github-actions-base >> "$TEST_OUTPUT"
  if [ $? -ne 0 ]; then
      echo "make failed"
      exit 1
  fi
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-github-actions-base.output"

  diff "$TESTDATA_ENV_PATH/.github/workflows/check.yml" "$ROOT_PATH/templates/github/workflows/check.yml"
  if [ $? -ne 0 ]; then
      echo "check.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/workflows/cloc.yml" "$ROOT_PATH/templates/github/workflows/cloc.yml"
  if [ $? -ne 0 ]; then
      echo "cloc.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/workflows/golangci-lint.yml" "$ROOT_PATH/templates/github/workflows/golangci-lint.yml"
  if [ $? -ne 0 ]; then
      echo "golangci-lint.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/workflows/release.yml" "$ROOT_PATH/templates/github/workflows/release.yml"
  if [ $? -ne 0 ]; then
      echo "release.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/workflows/test.yml" "$ROOT_PATH/templates/github/workflows/test.yml"
  if [ $? -ne 0 ]; then
      echo "test.yml file is not the same"
      exit 1
  fi
  if [ -e "$TESTDATA_ENV_PATH/.github/workflows/release-assets.yml" ]; then
      echo "The file $file_name exists in the folder $folder_path"
  fi
  diff "$TESTDATA_ENV_PATH/.github/actions/check-branch/action.yml" "$ROOT_PATH/templates/github/actions/check-branch/action.yml"
  if [ $? -ne 0 ]; then
      echo "action.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/actions/check-branch/check-branch.sh" "$ROOT_PATH/templates/github/actions/check-branch/check-branch.sh"
  if [ $? -ne 0 ]; then
      echo "check-branch.sh file is not the same"
      exit 1
  fi

  echo "OK"
}

Test_make_github_actions_release_assets() {
  printf "Test make github-actions-release-assets -> "
  rm -rf "$TESTDATA_ENV_PATH/.github"
  # Create a files for test
  create_files_test
  # Run enable recipe github-actions
  $tmake enable-recipe PACKAGE=dev NAME=github-actions > /dev/null
  # Run make to capture the output with the recipe enabled
  $tmake > "$TEST_OUTPUT"
  # Create GitHub Actions base files
  $tmake -e GITHUB_PATH=.github -e GITHUB_PATH_IGNORE=true github-actions > /dev/null
  # Running command to test
  $tmake -e GITHUB_PATH=.github -e GITHUB_PATH_IGNORE=true github-actions-release-assets >> "$TEST_OUTPUT"
  if [ $? -ne 0 ]; then
      echo "make failed"
      exit 1
  fi
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-github-actions-release-assets.output"

  diff "$TESTDATA_ENV_PATH/.github/workflows/check.yml" "$ROOT_PATH/templates/github/workflows/check.yml"
  if [ $? -ne 0 ]; then
      echo "check.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/workflows/cloc.yml" "$ROOT_PATH/templates/github/workflows/cloc.yml"
  if [ $? -ne 0 ]; then
      echo "cloc.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/workflows/golangci-lint.yml" "$ROOT_PATH/templates/github/workflows/golangci-lint.yml"
  if [ $? -ne 0 ]; then
      echo "golangci-lint.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/workflows/release.yml" "$ROOT_PATH/templates/github/workflows/release.yml"
  if [ $? -ne 0 ]; then
      echo "release.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/workflows/test.yml" "$ROOT_PATH/templates/github/workflows/test.yml"
  if [ $? -ne 0 ]; then
      echo "test.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/workflows/release-assets.yml" "$ROOT_PATH/templates/github/workflows/release-assets.yml"
  if [ $? -ne 0 ]; then
      echo "release-assets.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/actions/check-branch/action.yml" "$ROOT_PATH/templates/github/actions/check-branch/action.yml"
  if [ $? -ne 0 ]; then
      echo "action.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/actions/check-branch/check-branch.sh" "$ROOT_PATH/templates/github/actions/check-branch/check-branch.sh"
  if [ $? -ne 0 ]; then
      echo "check-branch.sh file is not the same"
      exit 1
  fi

  echo "OK"
}

Test_make_github_actions() {
  printf "Test make github-actions -> "
  rm -rf "$TESTDATA_ENV_PATH/.github"
  # Create a files for test
  create_files_test
  # Run enable recipe github-actions
  $tmake enable-recipe PACKAGE=dev NAME=github-actions > /dev/null
  # Run make to capture the output with the recipe enabled
  $tmake > "$TEST_OUTPUT"
  # Running command to test
  $tmake -e GITHUB_PATH=.github -e GITHUB_PATH_IGNORE=true github-actions >> "$TEST_OUTPUT"
  if [ $? -ne 0 ]; then
      echo "make failed"
      exit 1
  fi
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-github-actions.output"

  diff "$TESTDATA_ENV_PATH/.github/workflows/check.yml" "$ROOT_PATH/templates/github/workflows/check.yml"
  if [ $? -ne 0 ]; then
      echo "check.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/workflows/cloc.yml" "$ROOT_PATH/templates/github/workflows/cloc.yml"
  if [ $? -ne 0 ]; then
      echo "cloc.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/workflows/golangci-lint.yml" "$ROOT_PATH/templates/github/workflows/golangci-lint.yml"
  if [ $? -ne 0 ]; then
      echo "golangci-lint.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/workflows/release.yml" "$ROOT_PATH/templates/github/workflows/release.yml"
  if [ $? -ne 0 ]; then
      echo "release.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/workflows/test.yml" "$ROOT_PATH/templates/github/workflows/test.yml"
  if [ $? -ne 0 ]; then
      echo "test.yml file is not the same"
      exit 1
  fi
  if [ -e "$TESTDATA_ENV_PATH/.github/workflows/release-assets.yml" ]; then
      echo "The file $file_name exists in the folder $folder_path"
  fi
  diff "$TESTDATA_ENV_PATH/.github/actions/check-branch/action.yml" "$ROOT_PATH/templates/github/actions/check-branch/action.yml"
  if [ $? -ne 0 ]; then
      echo "action.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/actions/check-branch/check-branch.sh" "$ROOT_PATH/templates/github/actions/check-branch/check-branch.sh"
  if [ $? -ne 0 ]; then
      echo "check-branch.sh file is not the same"
      exit 1
  fi

  echo "OK"
}

Test_make_github_actions_with_release_assets_enabled() {
  printf "Test make github-actions with release-assets enabled -> "
  rm -rf "$TESTDATA_ENV_PATH/.github"
  # Create a files for test
  create_files_test
  # Run enable recipe github-actions
  $tmake enable-recipe PACKAGE=dev NAME=github-actions > /dev/null
  # Run make to capture the output with the recipe enabled
  $tmake > "$TEST_OUTPUT"
  # Enable release-assets
  echo "GITHUB_ACTIONS_RELEASE_ASSETS=true" >> Makefile
  # Running command to test
  $tmake -e GITHUB_PATH=.github -e GITHUB_PATH_IGNORE=true github-actions >> "$TEST_OUTPUT"
  if [ $? -ne 0 ]; then
      echo "make failed"
      exit 1
  fi
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-github-actions-release-assets-enabled.output"

  diff "$TESTDATA_ENV_PATH/.github/workflows/check.yml" "$ROOT_PATH/templates/github/workflows/check.yml"
  if [ $? -ne 0 ]; then
      echo "check.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/workflows/cloc.yml" "$ROOT_PATH/templates/github/workflows/cloc.yml"
  if [ $? -ne 0 ]; then
      echo "cloc.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/workflows/golangci-lint.yml" "$ROOT_PATH/templates/github/workflows/golangci-lint.yml"
  if [ $? -ne 0 ]; then
      echo "golangci-lint.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/workflows/release.yml" "$ROOT_PATH/templates/github/workflows/release.yml"
  if [ $? -ne 0 ]; then
      echo "release.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/workflows/test.yml" "$ROOT_PATH/templates/github/workflows/test.yml"
  if [ $? -ne 0 ]; then
      echo "test.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/workflows/release-assets.yml" "$ROOT_PATH/templates/github/workflows/release-assets.yml"
  if [ $? -ne 0 ]; then
      echo "release-assets.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/actions/check-branch/action.yml" "$ROOT_PATH/templates/github/actions/check-branch/action.yml"
  if [ $? -ne 0 ]; then
      echo "action.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/actions/check-branch/check-branch.sh" "$ROOT_PATH/templates/github/actions/check-branch/check-branch.sh"
  if [ $? -ne 0 ]; then
      echo "check-branch.sh file is not the same"
      exit 1
  fi

  echo "OK"
}

Test_make_github_dependabot() {
  printf "Test make github-dependabot -> "
  rm -rf "$TESTDATA_ENV_PATH/.github"
  # Create a files for test
  create_files_test
  # Run enable recipe github-actions
  $tmake enable-recipe PACKAGE=dev NAME=github-actions > /dev/null
  # Run make to capture the output with the recipe enabled
  $tmake > "$TEST_OUTPUT"
  # Running command to test
  $tmake -e GITHUB_PATH=.github -e GITHUB_PATH_IGNORE=true github-dependabot >> "$TEST_OUTPUT"
  if [ $? -ne 0 ]; then
      echo "make failed"
      exit 1
  fi
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-github-dependabot.output"

  diff "$TESTDATA_ENV_PATH/.github/dependabot.yml" "$ROOT_PATH/templates/github/dependabot.yml"
  if [ $? -ne 0 ]; then
      echo "dependabot.yml file is not the same"
      exit 1
  fi

  echo "OK"
}

Test_make_github() {
  printf "Test make github -> "
  rm -rf "$TESTDATA_ENV_PATH/.github"
  # Create a files for test
  create_files_test
  # Run enable recipe github-actions
  $tmake enable-recipe PACKAGE=dev NAME=github-actions > /dev/null
  # Run make to capture the output with the recipe enabled
  $tmake > "$TEST_OUTPUT"
  # Running command to test
  $tmake -e GITHUB_PATH=.github -e GITHUB_PATH_IGNORE=true github >> "$TEST_OUTPUT"
  if [ $? -ne 0 ]; then
      echo "make failed"
      exit 1
  fi
  # Removing the lines that are not part of the output but are appended by github actions
  strip_output
  # Checking the output
  check_output "$TEST_OUTPUT" "$OUTPUT_PATH/make-github.output"

  diff "$TESTDATA_ENV_PATH/.github/workflows/check.yml" "$ROOT_PATH/templates/github/workflows/check.yml"
  if [ $? -ne 0 ]; then
      echo "check.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/workflows/cloc.yml" "$ROOT_PATH/templates/github/workflows/cloc.yml"
  if [ $? -ne 0 ]; then
      echo "cloc.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/workflows/golangci-lint.yml" "$ROOT_PATH/templates/github/workflows/golangci-lint.yml"
  if [ $? -ne 0 ]; then
      echo "golangci-lint.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/workflows/release.yml" "$ROOT_PATH/templates/github/workflows/release.yml"
  if [ $? -ne 0 ]; then
      echo "release.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/workflows/test.yml" "$ROOT_PATH/templates/github/workflows/test.yml"
  if [ $? -ne 0 ]; then
      echo "test.yml file is not the same"
      exit 1
  fi
  if [ -e "$TESTDATA_ENV_PATH/.github/workflows/release-assets.yml" ]; then
      echo "The file $file_name exists in the folder $folder_path"
  fi
  diff "$TESTDATA_ENV_PATH/.github/actions/check-branch/action.yml" "$ROOT_PATH/templates/github/actions/check-branch/action.yml"
  if [ $? -ne 0 ]; then
      echo "action.yml file is not the same"
      exit 1
  fi
  diff "$TESTDATA_ENV_PATH/.github/actions/check-branch/check-branch.sh" "$ROOT_PATH/templates/github/actions/check-branch/check-branch.sh"
  if [ $? -ne 0 ]; then
      echo "check-branch.sh file is not the same"
      exit 1
  fi

  diff "$TESTDATA_ENV_PATH/.github/dependabot.yml" "$ROOT_PATH/templates/github/dependabot.yml"
  if [ $? -ne 0 ]; then
      echo "dependabot.yml file is not the same"
      exit 1
  fi

  echo "OK"
}