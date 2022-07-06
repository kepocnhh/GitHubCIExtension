#!/bin/bash

echo "VCS tag push..."

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

git -C $REPOSITORY push --tag \
 || . ex/util/throw 41 "Git tag push error!"

exit 0
