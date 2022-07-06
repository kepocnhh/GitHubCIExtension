#!/bin/bash

echo "VCS push..."

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

git -C $REPOSITORY push \
 || . ex/util/throw 41 "Git push error!"

exit 0
