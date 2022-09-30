#!/bin/bash

echo "GitHub issue patch..."

. ex/util/args/require $# 2

ISSUE_NUMBER="$1"
BODY="$2"

. ex/util/require ISSUE_NUMBER BODY

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .url REPOSITORY_URL

CODE=$(curl -w %{http_code} -o assemble/github/issue${ISSUE_NUMBER}.json -X PATCH \
 "$REPOSITORY_URL/issues/$ISSUE_NUMBER" \
 -H "Authorization: token $VCS_PAT" \
 -d "$BODY")
if test $CODE -ne 200; then
 echo "GitHub patch issue #$ISSUE_NUMBER error!"
 echo "Request error with response code $CODE!"
 jq . assemble/github/issue${ISSUE_NUMBER}.json # todo
 exit 31
fi

. ex/util/json -f assemble/github/issue${ISSUE_NUMBER}.json \
 -sfs .html_url ISSUE_HTML_URL

echo "The issue $ISSUE_HTML_URL is patched."
