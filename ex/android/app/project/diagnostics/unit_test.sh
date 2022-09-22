#!/bin/bash

echo "Project diagnostics unit test..."

. ex/util/require BUILD_VARIANT

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

ENVIRONMENT=repository/buildSrc/src/main/resources/json/verify/unit_test.json

TYPE="UNIT_TEST"
TASK=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.task") \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
TASK=${TASK//"?"/"${BUILD_VARIANT^}"}
TITLE=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.title") \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
echo "Task verify \"${TITLE}\"..."
gradle -p $REPOSITORY -q "$TASK"; CODE=$?
if test $CODE -ne 0; then
 RELATIVE=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.path") \
  || . ex/util/throw $? "$(cat /tmp/jqx.o)"
 RELATIVE=${RELATIVE//"?"/"$BUILD_VARIANT"}
 mkdir -p diagnostics/report/$RELATIVE
 REPORT=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.report") \
  || . ex/util/throw $? "$(cat /tmp/jqx.o)"
 REPORT=${REPORT//"?"/"${BUILD_VARIANT^}"}
 . ex/util/assert -d $REPOSITORY/$REPORT
 cp -r $REPOSITORY/$REPORT/* diagnostics/report/$RELATIVE || exit 1 # todo
 echo "$(jq -Mc ".$TYPE.path=\"$RELATIVE\"" diagnostics/summary.json)" > diagnostics/summary.json \
  && echo "$(jq -Mc ".$TYPE.title=\"$TITLE\"" diagnostics/summary.json)" > diagnostics/summary.json \
  || exit 121
else
 TYPE="TEST_COVERAGE"
 TASK=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.task") \
  || . ex/util/throw $? "$(cat /tmp/jqx.o)"
 TASK=${TASK//"?"/"${BUILD_VARIANT^}"}
 TITLE=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.title") \
  || . ex/util/throw $? "$(cat /tmp/jqx.o)"
 echo "Task \"${TITLE}\"..."
 gradle -p $REPOSITORY -q "$TASK" || exit 1 # todo
 TASK=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.verification.task") \
  || . ex/util/throw $? "$(cat /tmp/jqx.o)"
 TASK=${TASK//"?"/"${BUILD_VARIANT^}"}
 echo "Task verify \"${TITLE}\"..."
 gradle -p $REPOSITORY -q "$TASK"; CODE=$?
 if test $CODE -ne 0; then
  RELATIVE=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.path") \
   || . ex/util/throw $? "$(cat /tmp/jqx.o)"
  RELATIVE=${RELATIVE//"?"/"$BUILD_VARIANT"}
  mkdir -p diagnostics/report/$RELATIVE
  REPORT=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.report") \
   || . ex/util/throw $? "$(cat /tmp/jqx.o)"
  REPORT=${REPORT//"?"/"${BUILD_VARIANT^}"}
  . ex/util/assert -d $REPOSITORY/$REPORT
  cp -r $REPOSITORY/$REPORT/* diagnostics/report/$RELATIVE || exit 1 # todo
  echo "$(jq -Mc ".$TYPE.path=\"$RELATIVE\"" diagnostics/summary.json)" > diagnostics/summary.json \
   && echo "$(jq -Mc ".$TYPE.title=\"$TITLE\"" diagnostics/summary.json)" > diagnostics/summary.json \
   || exit 122
 fi
fi

TYPES="$(jq -Mcer "keys" diagnostics/summary.json)" || exit 1 # todo
if test "$TYPES" == "[]"; then
 echo "Diagnostics should have determined the cause of the failure!"; exit 0
fi

echo "Diagnostics have determined the cause of the failure - this is: $TYPES."
