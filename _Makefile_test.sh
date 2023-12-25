#!/bin/bash

TESTDATA_PATH="testdata"
TEST_OUTPUT="test.out"
MAKEFILE_FILE=_Makefile

echo -e

echo "Test make plugin bool64/dev"
cat "$MAKEFILE_FILE"> Makefile.test
make -f Makefile.test > "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-bool64-dev.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "make OK"

echo -e

echo "Test make search-recipes with plugin bool64/dev"
cat "$MAKEFILE_FILE"> Makefile.test
make -f Makefile.test search-recipes > "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-search-recipes-bool64-dev.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "make search-recipes OK"

echo -e

echo "Test make list-recipes with plugin bool64/dev"
cat "$MAKEFILE_FILE"> Makefile.test
make -f Makefile.test list-recipes > "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-list-recipes-bool64-dev.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "make list-recipes OK"

echo -e

echo "Test make enable-recipe PLUGIN=bool64/dev NAME=lint with plugin bool64/dev"
cat "$MAKEFILE_FILE"> Makefile.test
make -f Makefile.test -e MAKEFILE_FILE=Makefile.test enable-recipe PLUGIN=bool64/dev NAME=lint > "$TEST_OUTPUT"
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
diff "$TEST_OUTPUT" "$TESTDATA_PATH/make-enable-recipe-bool64-dev-lint.output"
if [ $? -ne 0 ]; then
    echo "make output is not the same"
    exit 1
fi
echo "make enable-recipe OK"

echo -e