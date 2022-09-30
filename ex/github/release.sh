#!/bin/bash

echo "GitHub release..."

. ex/util/args/require $# 1

BODY="$1"

. ex/util/json -j "$BODY" \
 -sfs .name RELEASE_NAME

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .url REPOSITORY_URL

CODE=0
OUTPUT=/tmp/output
CODE=$(curl -s -w %{http_code} -o $OUTPUT -X POST \
 "$REPOSITORY_URL/releases" \
 -H "Authorization: token $VCS_PAT" \
 -d "$BODY")
if test $CODE -ne 201; then
 echo "GitHub release \"$RELEASE_NAME\" error!"
 echo "Request error with response code $CODE!"
 cat $OUTPUT
 exit 21
fi

mv $OUTPUT assemble/github/release.json \
 || . ex/util/throw 31 "Illegal state!"

. ex/util/json -f assemble/github/release.json \
 -sfs .html_url RELEASE_HTML_URL

echo "The release $RELEASE_HTML_URL is ready."
