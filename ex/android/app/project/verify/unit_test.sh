#!/bin/bash

echo "Project verify unit test..."

. ex/util/require BUILD_VARIANT

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

ENVIRONMENT=repository/buildSrc/src/main/resources/json/verify/unit_test.json

TYPE="UNIT_TEST"
. ex/util/json -f $ENVIRONMENT -sfs ".${TYPE}.task" TASK
TASK=${TASK//"?"/"${BUILD_VARIANT^}"}
echo "Task verify \"$TASK\"..."
gradle -p $REPOSITORY -q "$TASK" \
 || . ex/util/throw 21 "Unit test error!"

TYPE="TEST_COVERAGE"
. ex/util/json -f $ENVIRONMENT -sfs ".${TYPE}.task" TASK
TASK=${TASK//"?"/"${BUILD_VARIANT^}"}
echo "Task verify \"$TASK\"..."
gradle -p $REPOSITORY -q "$TASK" \
 || . ex/util/throw 31 "Illegal state!"
. ex/util/json -f $ENVIRONMENT -sfs ".${TYPE}.task" TASK
TASK=${TASK//"?"/"${BUILD_VARIANT^}"}
echo "Task verify \"$TASK\"..."
gradle -p $REPOSITORY -q "$TASK" \
 || . ex/util/throw 22 "Test coverage verification error!"
