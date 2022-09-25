#!/bin/bash

echo "GitHub issue..."

. ex/util/args/require $# 1

ISSUE_NUMBER="$1"

. ex/util/require ISSUE_NUMBER

REPOSITORY_URL=$(ex/util/jqx -sfs assemble/vcs/repository.json .url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

CODE=$(curl -w %{http_code} -o assemble/github/issue${ISSUE_NUMBER}.json \
 "$REPOSITORY_URL/issues/$ISSUE_NUMBER")
if test $CODE -ne 200; then
 echo "GitHub issue #$ISSUE_NUMBER error!"
 echo "Request error with response code $CODE!"
 exit 11
fi

ISSUE_HTML_URL=$(ex/util/jqx -sfs assemble/github/issue${ISSUE_NUMBER}.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

echo "The issue $ISSUE_HTML_URL is ready."
