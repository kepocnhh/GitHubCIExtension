#!/bin/bash

echo "Assemble project common..."

. ex/util/require REPOSITORY_OWNER REPOSITORY_NAME

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

gradle -q -p $REPOSITORY saveCommonInfo \
 || . ex/util/throw 11 "Save common info error!"

JSON_FILE=$REPOSITORY/build/common.json
. ex/util/assert -f $JSON_FILE
cp $JSON_FILE assemble/project/common.json

. ex/util/json -f assemble/project/common.json \
 -sfs .repository.owner ACTUAL_OWNER \
 -sfs .repository.name ACTUAL_NAME

. ex/util/assert -eq REPOSITORY_OWNER ACTUAL_OWNER
. ex/util/assert -eq REPOSITORY_NAME ACTUAL_NAME
