#!/bin/bash

echo "Assemble project common..."

. ex/util/require REPOSITORY_OWNER REPOSITORY_NAME

gradle -p repository saveCommonInfo \
 || . ex/util/throw 11 "Save common info error $?!"

JSON_FILE=$(pwd)/repository/build/common.json
. ex/util/assert -f $JSON_FILE
cp $JSON_FILE assemble/project/common.json

ACTUAL_OWNER=$(ex/util/jqx -sfs assemble/project/common.json .repository.owner) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
. ex/util/assert -eq REPOSITORY_OWNER ACTUAL_OWNER

ACTUAL_NAME=$(ex/util/jqx -sfs assemble/project/common.json .repository.name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
. ex/util/assert -eq REPOSITORY_NAME ACTUAL_NAME

exit 0
