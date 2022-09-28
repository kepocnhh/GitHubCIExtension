#!/bin/bash

echo "GitHub release..."

. ex/util/args/require $# 1

BODY="$1"

RELEASE_NAME=$(ex/util/jqj -sfs "$BODY" .name) \
 || . ex/util/throw $? "$(cat /tmp/jqj.o)"
. ex/util/jq/write REPOSITORY_URL -sfs assemble/vcs/repository.json .url

CODE=0
CODE=$(curl -s -w %{http_code} -o assemble/github/release.json -X POST \
 "$REPOSITORY_URL/releases" \
 -H "Authorization: token $VCS_PAT" \
 -d "$BODY")
if test $CODE -ne 201; then
 echo "GitHub release $RELEASE_NAME error!"
 echo "Request error with response code $CODE!"
 exit 31
fi

. ex/util/jq/write RELEASE_HTML_URL -sfs assemble/github/release.json .html_url

echo "The release $RELEASE_HTML_URL is ready."
