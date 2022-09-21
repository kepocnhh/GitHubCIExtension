#!/bin/bash

echo "Project diagnostics..."

[ $# -eq 0 ] && . ex/util/throw 11 "Script needs more arguments!"

. ex/util/require BUILD_VARIANT

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

CODE=0
for (( ARG_NUMBER=1; ARG_NUMBER<=$#; ARG_NUMBER++ )); do
 ENVIRONMENT="${!ARG_NUMBER}"
 . ex/util/assert -f $ENVIRONMENT
 echo "Start environment [$ARG_NUMBER/$#] ${ENVIRONMENT}..."
 ARRAY=($(jq -Mcer "keys|.[]" $ENVIRONMENT))
 SIZE=${#ARRAY[*]}
 for ((TYPE_NUMBER=0; TYPE_NUMBER<$SIZE; TYPE_NUMBER++)); do
  TYPE="${ARRAY[TYPE_NUMBER]}"
  BY_VARIANT=$(ex/util/jqx -sb $ENVIRONMENT ".${TYPE}.byVariant") \
   || . ex/util/throw $? "$(cat /tmp/jqx.o)"
  TASK=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.task") \
   || . ex/util/throw $? "$(cat /tmp/jqx.o)"
  test "$BY_VARIANT" == "true" && TASK=${TASK//"?"/"${BUILD_VARIANT^}"}
  TITLE=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.title") \
   || . ex/util/throw $? "$(cat /tmp/jqx.o)"
  echo "Task [$((TYPE_NUMBER+1))/$SIZE] verify \"${TITLE}\"..."
  gradle -p $REPOSITORY -q "$TASK"; CODE=$?
  if test $CODE -ne 0; then
   RELATIVE=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.path") \
    || . ex/util/throw $? "$(cat /tmp/jqx.o)"
   test "$BY_VARIANT" == "true" && RELATIVE=${RELATIVE//"?"/"$BUILD_VARIANT"}
   mkdir -p diagnostics/report/$RELATIVE
   REPORT=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.report") \
    || . ex/util/throw $? "$(cat /tmp/jqx.o)"
   test "$BY_VARIANT" == "true" && REPORT=${REPORT//"?"/"$BUILD_VARIANT"}
   . ex/util/assert -d $REPOSITORY/$REPORT
   cp -r $REPOSITORY/$REPORT/* diagnostics/report/$RELATIVE || exit 1 # todo
   echo "$(jq -Mc ".$TYPE.path=\"$RELATIVE\"" diagnostics/summary.json)" > diagnostics/summary.json \
    && echo "$(jq -Mc ".$TYPE.title=\"$TITLE\"" diagnostics/summary.json)" > diagnostics/summary.json \
    || exit $((100+TYPE_NUMBER))
  fi
 done
done

TYPES="$(jq -Mcer "keys" diagnostics/summary.json)" || exit 1 # todo
if test "$TYPES" == "[]"; then
 echo "Diagnostics should have determined the cause of the failure!"; exit 1 # todo
fi

echo "Diagnostics have determined the cause of the failure - this is: $TYPES."
