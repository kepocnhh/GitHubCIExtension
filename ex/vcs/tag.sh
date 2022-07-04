#!/bin/bash

echo "VCS tag..."

. ex/util/args/require $# 1

TAG="$1"

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

git -C $REPOSITORY tag "$TAG" \
 || . ex/util/throw 41 "Git tag error!"

exit 0
