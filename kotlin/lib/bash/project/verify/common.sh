#!/bin/bash

echo "Project verify..."

[ $# -eq 0 ] && . ex/util/throw 11 "Script needs more arguments!"

for (( i=1; i<=$#; i++ )); do
 ENVIRONMENT="${!i}"
 . ex/util/assert -f $ENVIRONMENT
 ARRAY=($(jq -Mcer "keys|.[]" $ENVIRONMENT))
 for ((j=0; j<${#ARRAY[*]}; j++)); do
  TYPE="${ARRAY[j]}"
  TASK=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.task") \
   || . ex/util/throw $? "$(cat /tmp/jqx.o)"
  gradle -p repository "$TASK" \
   || . ex/util/throw $((100+j)) "Gradle $TASK error!"
 done
done
