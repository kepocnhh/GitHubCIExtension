#!/bin/bash

echo "Project pre verify..."

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

gradle -p $REPOSITORY verifyService \
 || . ex/util/throw 11 "Gradle verify service error!"

exit 0
