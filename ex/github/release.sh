#!/bin/bash

echo "GitHub release..."

. ex/util/args/require $# 1

BODY="$1"

RELEASE_NAME=$(ex/util/jqj -sfs "$BODY" .name) \
 || . ex/util/throw $? "$(cat /tmp/jqj.o)"
. ex/util/jq/write REPOSITORY_URL -sfs assemble/vcs/repository.json .url

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

. ex/util/jq/write RELEASE_HTML_URL -sfs assemble/github/release.json .html_url

echo "The release $RELEASE_HTML_URL is ready."
