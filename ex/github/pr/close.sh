#!/bin/bash

echo "VCS pull request close..."

. ex/util/require VCS_PAT PR_NUMBER

BODY="$(echo "{}" | jq -Mc ".state=\"close\"")"
REPOSITORY_URL=$(ex/util/jqx -sfs assemble/vcs/repository.json .url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

CODE=0
CODE=$(curl -w %{http_code} -o /dev/null -X PATCH \
 "$REPOSITORY_URL/pulls/$PR_NUMBER" \
 -H "Authorization: token $VCS_PAT" \
 -d "$BODY")
if test $CODE -ne 200; then
 echo "Close pull request #$PR_NUMBER error!"
 echo "Request error with response code $CODE!"
 exit 31
fi
