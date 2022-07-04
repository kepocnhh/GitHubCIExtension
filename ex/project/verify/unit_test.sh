#!/bin/bash

echo "Project verify..."

CODE=0
ENVIRONMENT=repository/buildSrc/src/main/resources/json/unit_test.json
TYPE="UNIT_TEST"
TASK=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.task") \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
gradle -p repository "$TASK"; CODE=$?
if test $CODE -ne 0; then
 echo "Unit test error!"; exit 121
else
 TYPE="TEST_COVERAGE"
 TASK=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.task") \
  || . ex/util/throw $? "$(cat /tmp/jqx.o)"
 gradle -p repository "$TASK" || exit 1 # todo
 TASK=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.verification.task") \
  || . ex/util/throw $? "$(cat /tmp/jqx.o)"
 gradle -p repository "$TASK" \
  || . ex/util/throw 122 "Test coverage verification error!"
fi

exit 0
