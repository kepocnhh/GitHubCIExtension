#!/bin/bash

echo "Project diagnostics..."

. ex/util/args/require $# 1

ENVIRONMENT="$1"

CODE=0

ARRAY=($(jq -Mcer "keys|.[]" $ENVIRONMENT))
SIZE=${#ARRAY[*]}
for ((i=0; i<SIZE; i++)); do
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

TYPES="$(jq -Mcer "keys" diagnostics/summary.json)" || exit 1 # todo
if test "$TYPES" == "[]"; then
 echo "Diagnostics should have determined the cause of the failure!"; exit 0
fi

echo "Diagnostics have determined the cause of the failure - this is: $TYPES."

exit 0
