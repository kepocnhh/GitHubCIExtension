#!/bin/bash

echo "Workflow pull request unstable assemble project artifact..."

REQUIRE_FILLED_STRING="select((.!=null)and(type==\"string\")and(.!=\"\"))"

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

VERSION_NAME=$(ex/util/jqx -sfs assemble/project/common.json ".version.name") \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

. ex/util/require REPOSITORY_NAME

ARTIFACT="${REPOSITORY_NAME}-${VERSION_NAME}-UNSTABLE.jar"

gradle -p "$REPOSITORY" lib:assembleUnstableJar \
 || . ex/util/throw 12 "Assemble \"$ARTIFACT\" error $CODE!"

. ex/util/assert -f $REPOSITORY/lib/build/libs/$ARTIFACT

rm assemble/project/artifact/$ARTIFACT
mkdir -p assemble/project/artifact
mv $REPOSITORY/lib/build/libs/$ARTIFACT assemble/project/artifact/$ARTIFACT || exit 1 # todo

exit 0
