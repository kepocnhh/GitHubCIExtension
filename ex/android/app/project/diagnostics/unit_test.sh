#!/bin/bash

echo "Project diagnostics unit test..."

. ex/util/require BUILD_VARIANT

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

ENVIRONMENT=repository/buildSrc/src/main/resources/json/verify/unit_test.json

TYPE="UNIT_TEST"
. ex/util/json -f $ENVIRONMENT \
 -sfs ".${TYPE}.task" TASK \
 -sfs ".${TYPE}.title" TITLE

TASK=${TASK//"?"/"${BUILD_VARIANT^}"}
echo "Task verify \"${TITLE}\"..."
gradle -p $REPOSITORY -q "$TASK"; CODE=$?
if test $CODE -ne 0; then
 . ex/util/json -f $ENVIRONMENT \
  -sfs ".${TYPE}.path" RELATIVE \
  -sfs ".${TYPE}.report" REPORT
 RELATIVE=${RELATIVE//"?"/"$BUILD_VARIANT"}
 mkdir -p diagnostics/report/$RELATIVE
 REPORT=${REPORT//"?"/"${BUILD_VARIANT^}"}
 . ex/util/assert -d $REPOSITORY/$REPORT
 cp -r $REPOSITORY/$REPORT/* diagnostics/report/$RELATIVE || exit 1 # todo
 echo "$(jq -Mc ".$TYPE.path=\"$RELATIVE\"" diagnostics/summary.json)" > diagnostics/summary.json \
  && echo "$(jq -Mc ".$TYPE.title=\"$TITLE\"" diagnostics/summary.json)" > diagnostics/summary.json \
  || exit 121
else
 TYPE="TEST_COVERAGE"
 . ex/util/json -f $ENVIRONMENT \
  -sfs ".${TYPE}.task" TASK \
  -sfs ".${TYPE}.title" TITLE
 TASK=${TASK//"?"/"${BUILD_VARIANT^}"}
 echo "Task \"${TITLE}\"..."
 gradle -p $REPOSITORY -q "$TASK" || exit 1 # todo
 . ex/util/json -f $ENVIRONMENT \
  -sfs ".${TYPE}.verification.task" TASK
 TASK=${TASK//"?"/"${BUILD_VARIANT^}"}
 echo "Task verify \"${TITLE}\"..."
 gradle -p $REPOSITORY -q "$TASK"; CODE=$?
 if test $CODE -ne 0; then
  . ex/util/json -f $ENVIRONMENT \
   -sfs ".${TYPE}.path" RELATIVE \
   -sfs ".${TYPE}.report" REPORT
  RELATIVE=${RELATIVE//"?"/"$BUILD_VARIANT"}
  mkdir -p diagnostics/report/$RELATIVE
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
