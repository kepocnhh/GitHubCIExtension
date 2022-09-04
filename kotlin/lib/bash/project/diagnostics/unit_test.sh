#!/bin/bash

echo "Project diagnostics unit test..."

ENVIRONMENT=repository/buildSrc/src/main/resources/json/verify/unit_test.json
TYPE="UNIT_TEST"
TASK=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.task") \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
gradle -p repository "$TASK"; CODE=$?
if test $CODE -ne 0; then
 RELATIVE=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.path") \
  || . ex/util/throw $? "$(cat /tmp/jqx.o)"
 TITLE=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.title") \
  || . ex/util/throw $? "$(cat /tmp/jqx.o)"
 mkdir -p diagnostics/report/$RELATIVE
 REPORT=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.report") \
  || . ex/util/throw $? "$(cat /tmp/jqx.o)"
 cp -r repository/$REPORT/* diagnostics/report/$RELATIVE || exit 1 # todo
 echo "$(jq -Mc ".$TYPE.path=\"$RELATIVE\"" diagnostics/summary.json)" > diagnostics/summary.json \
  && echo "$(jq -Mc ".$TYPE.title=\"$TITLE\"" diagnostics/summary.json)" > diagnostics/summary.json \
  || exit 121
else
 TYPE="TEST_COVERAGE"
 TASK=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.task") \
  || . ex/util/throw $? "$(cat /tmp/jqx.o)"
 gradle -p repository "$TASK" || exit 1 # todo
 TASK=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.verification.task") \
  || . ex/util/throw $? "$(cat /tmp/jqx.o)"
 gradle -p repository "$TASK"; CODE=$?
 if test $CODE -ne 0; then
  RELATIVE=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.path") \
   || . ex/util/throw $? "$(cat /tmp/jqx.o)"
  TITLE=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.title") \
   || . ex/util/throw $? "$(cat /tmp/jqx.o)"
  mkdir -p diagnostics/report/$RELATIVE
  REPORT=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.report") \
   || . ex/util/throw $? "$(cat /tmp/jqx.o)"
  cp -r repository/$REPORT/* diagnostics/report/$RELATIVE || exit 1 # todo
  echo "$(jq -Mc ".$TYPE.path=\"$RELATIVE\"" diagnostics/summary.json)" > diagnostics/summary.json \
   && echo "$(jq -Mc ".$TYPE.title=\"$TITLE\"" diagnostics/summary.json)" > diagnostics/summary.json \
   || exit 122
 fi
fi

TYPES="$(jq -Mcer "keys" diagnostics/summary.json)" || exit 1 # todo
if test "$TYPES" == "[]"; then
 echo "Diagnostics should have determined the cause of the failure!"; exit 1 # todo
fi

echo "Diagnostics have determined the cause of the failure - this is: $TYPES."
