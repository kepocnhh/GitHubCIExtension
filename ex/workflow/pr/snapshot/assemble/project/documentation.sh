#!/bin/bash

echo "Workflow pull request snapshot assemble project documentation..."

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

gradle -p "$REPOSITORY" lib:assembleSnapshotDocumentation \
 || . ex/util/throw 11 "Assemble documentation error $?!"

DOCUMENTATION_PATH=$REPOSITORY/lib/build/documentation/snapshot
. ex/util/assert -d $DOCUMENTATION_PATH

rm -rf assemble/project/documentation
mkdir -p assemble/project/documentation
cp -r $DOCUMENTATION_PATH/* assemble/project/documentation || exit 1 # todo

exit 0
