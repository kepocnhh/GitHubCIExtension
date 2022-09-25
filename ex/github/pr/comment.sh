#!/bin/bash

echo "GitHub pull request comment..."

. ex/util/args/require $# 1

COMMENT="$1"
COMMENT=${COMMENT//$'\n'/"\n"}
COMMENT=${COMMENT//"\""/"\\\""}

REPOSITORY_URL=$(ex/util/jqx -sfs assemble/vcs/repository.json .url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

. ex/util/require VCS_PAT PR_NUMBER COMMENT

BODY="$(echo "{}" | jq -Mc ".body=\"$COMMENT\"")"

CODE=0
CODE=$(curl -w %{http_code} -o /dev/null -X POST \
 "$REPOSITORY_URL/issues/$PR_NUMBER/comments" \
 -H "Authorization: token $VCS_PAT" \
 -d "$BODY")
if test $CODE -ne 201; then
 echo "Post comment to pull request #$PR_NUMBER error!"
 echo "Request error with response code $CODE!"
 exit 31
fi