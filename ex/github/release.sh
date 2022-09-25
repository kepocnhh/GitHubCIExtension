#!/bin/bash

echo "GitHub release..."

. ex/util/args/require $# 1

BODY="$1"

CODE=0
RELEASE_NAME=$(ex/util/jqj -sfs "$BODY" .name) \
 || . ex/util/throw $? "$(cat /tmp/jqj.o)"

REPOSITORY_URL=$(ex/util/jqx -sfs assemble/vcs/repository.json .url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

CODE=$(curl -w %{http_code} -o assemble/github/release.json -X POST \
 "$REPOSITORY_URL/releases" \
 -H "Authorization: token $VCS_PAT" \
 -d "$BODY")
if test $CODE -ne 201; then
 echo "GitHub release $RELEASE_NAME error!"
 echo "Request error with response code $CODE!"
 exit 31
fi

RELEASE_ID=$(ex/util/jqx -si assemble/github/release.json .id) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
RELEASE_HTML_URL=$(ex/util/jqx -sfs assemble/github/release.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

echo "The release $RELEASE_HTML_URL is ready."
