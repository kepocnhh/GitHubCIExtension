#!/bin/bash

echo "Project verify..."

[ $# -eq 0 ] && . ex/util/throw 11 "Script needs more arguments!"

for (( ARG_NUMBER=1; ARG_NUMBER<=$#; ARG_NUMBER++ )); do
 ENVIRONMENT="${!ARG_NUMBER}"
 . ex/util/assert -f $ENVIRONMENT
 echo "Start environment [$ARG_NUMBER/$#] ${ENVIRONMENT}..."
 ARRAY=($(jq -Mcer "keys|.[]" $ENVIRONMENT))
 SIZE=${#ARRAY[*]}
 for ((j=0; j<$SIZE; j++)); do
  TYPE="${ARRAY[j]}"
  TASK=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.task") \
   || . ex/util/throw $? "$(cat /tmp/jqx.o)"
  TITLE=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.title") \
   || . ex/util/throw $? "$(cat /tmp/jqx.o)"
  echo "Task [$((j+1))/$SIZE] verify \"${TITLE}\"..."
  gradle -p repository -q "$TASK" \
   || . ex/util/throw $((100+j)) "Gradle $TASK error!"
 done
done
