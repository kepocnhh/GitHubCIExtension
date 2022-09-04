#!/bin/bash

echo "Project diagnostics..."

[ $# -eq 0 ] && . ex/util/throw 11 "Script needs more arguments!"

CODE=0
for (( j=1; j<=$#; j++ )); do
 ENVIRONMENT="${!j}"
 . ex/util/assert -f $ENVIRONMENT
 ARRAY=($(jq -Mcer "keys|.[]" $ENVIRONMENT))
 for ((i=0; i<${#ARRAY[*]}; i++)); do
  TYPE="${ARRAY[i]}"
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
    || exit $((100+i))
  fi
 done
done

TYPES="$(jq -Mcer "keys" diagnostics/summary.json)" || exit 1 # todo
if test "$TYPES" == "[]"; then
 echo "Diagnostics should have determined the cause of the failure!"; exit 0
fi

echo "Diagnostics have determined the cause of the failure - this is: $TYPES."
