#!/bin/bash

echo "VCS pull request close..."

. ex/util/require VCS_PAT PR_NUMBER

BODY="$(echo "{}" | jq -Mc ".state=\"close\"")"

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .url REPOSITORY_URL

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
