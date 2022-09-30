#!/bin/bash

echo "GitHub issue..."

. ex/util/args/require $# 1

ISSUE_NUMBER="$1"

. ex/util/require ISSUE_NUMBER

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .url REPOSITORY_URL

CODE=$(curl -w %{http_code} -o assemble/github/issue${ISSUE_NUMBER}.json \
 "$REPOSITORY_URL/issues/$ISSUE_NUMBER")
if test $CODE -ne 200; then
 echo "GitHub issue #$ISSUE_NUMBER error!"
 echo "Request error with response code $CODE!"
 exit 11
fi

. ex/util/json -f assemble/github/issue${ISSUE_NUMBER}.json \
 -sfs .html_url ISSUE_HTML_URL

echo "The issue $ISSUE_HTML_URL is ready."
