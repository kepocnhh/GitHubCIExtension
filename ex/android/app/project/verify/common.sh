#!/bin/bash

echo "Project verify..."

. ex/util/require BUILD_VARIANT

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

for (( ARG_NUMBER=1; ARG_NUMBER<=$#; ARG_NUMBER++ )); do
 ENVIRONMENT="${!ARG_NUMBER}"
 . ex/util/assert -f $ENVIRONMENT
 echo "Start environment [$ARG_NUMBER/$#] ${ENVIRONMENT}..."
 ARRAY=($(jq -Mcer "keys|.[]" $ENVIRONMENT))
 SIZE=${#ARRAY[*]}
 for ((TYPE_NUMBER=0; TYPE_NUMBER<$SIZE; TYPE_NUMBER++)); do
  TYPE="${ARRAY[TYPE_NUMBER]}"
  . ex/util/json -f $ENVIRONMENT \
   -sb ".${TYPE}.byVariant" BY_VARIANT \
   -sfs ".${TYPE}.task" TASK \
   -sfs ".${TYPE}.title" TITLE
  test "$BY_VARIANT" == "true" && TASK=${TASK//"?"/"${BUILD_VARIANT^}"}
  echo "Task [$((TYPE_NUMBER+1))/$SIZE] verify \"${TITLE}\"..."
  gradle -p $REPOSITORY -q "$TASK" \
   || . ex/util/throw $((100+TYPE_NUMBER)) "Gradle $TASK error!"
 done
done
