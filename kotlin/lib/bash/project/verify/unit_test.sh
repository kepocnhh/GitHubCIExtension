#!/bin/bash

echo "Project verify unit test..."

ENVIRONMENT=repository/buildSrc/src/main/resources/json/verify/unit_test.json

TYPE="UNIT_TEST"
TASK=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.task") \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
echo "Task verify \"$TASK\"..."
gradle -p repository -q "$TASK" \
 || . ex/util/throw 121 "Unit test error!"

TYPE="TEST_COVERAGE"
TASK=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.task") \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
echo "Task verify \"$TASK\"..."
gradle -p repository -q "$TASK" || exit 1 # todo
TASK=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.verification.task") \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
echo "Task verify \"$TASK\"..."
gradle -p repository -q "$TASK" \
 || . ex/util/throw 122 "Test coverage verification error!"
