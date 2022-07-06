#!/bin/bash

echo "GitHub issue patch..."

. ex/util/args/require $# 2

ISSUE_NUMBER="$1"
BODY="$2"

. ex/util/require VCS_DOMAIN REPOSITORY_OWNER REPOSITORY_NAME ISSUE_NUMBER BODY

CODE=$(curl -w %{http_code} -o assemble/github/issue${ISSUE_NUMBER}.json -X PATCH \
 "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/issues/$ISSUE_NUMBER" \
 -H "Authorization: token $VCS_PAT" \
 -d "$BODY")
if test $CODE -ne 200; then
 echo "GitHub patch issue #$ISSUE_NUMBER error!"
 echo "Request error with response code $CODE!"
 jq . assemble/github/issue${ISSUE_NUMBER}.json # todo
 exit 31
fi

ISSUE_HTML_URL=$(ex/util/jqx -sfs assemble/github/issue${ISSUE_NUMBER}.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

echo "The issue $ISSUE_HTML_URL is patched."

exit 0
