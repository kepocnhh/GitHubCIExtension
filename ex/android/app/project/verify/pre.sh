#!/bin/bash

echo "Project pre verify..."

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

echo "Verify service..."
gradle -q -p $REPOSITORY verifyService \
 || . ex/util/throw 11 "Gradle verify service error!"
