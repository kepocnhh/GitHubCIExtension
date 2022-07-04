#!/bin/bash

echo "Project verify..."

. ex/util/args/require $# 1

ENVIRONMENT="$1"

ARRAY=($(jq -Mcer "keys|.[]" $ENVIRONMENT))
SIZE=${#ARRAY[*]}
for ((i=0; i<SIZE; i++)); do
 TYPE="${ARRAY[i]}"
 TASK=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.task") \
  || . ex/util/throw $? "$(cat /tmp/jqx.o)"
 gradle -p repository "$TASK" \
  || . ex/util/throw $((100+i)) "Gradle $TASK error!"
done

exit 0
