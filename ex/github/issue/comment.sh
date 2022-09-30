#!/bin/bash

echo "GitHub issue comment..."

. ex/util/args/require $# 2

ISSUE_NUMBER="$1"
MESSAGE="$2"

. ex/util/require ISSUE_NUMBER MESSAGE

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .url REPOSITORY_URL

MESSAGE=${MESSAGE//\"/\\\"}
CODE=$(curl -w %{http_code} -o /tmp/comment.json -X POST \
 "$REPOSITORY_URL/issues/$ISSUE_NUMBER/comments" \
 -H "Authorization: token $VCS_PAT" \
 -d "{\"body\":\"$MESSAGE\"}")
if test $CODE -ne 201; then
 echo "GitHub comment issue #$ISSUE_NUMBER error!"
 echo "Request error with response code $CODE!"
 exit 31
fi

. ex/util/json -f /tmp/comment.json \
 -sfs .html_url COMMENT_HTML_URL

echo "The comment $COMMENT_HTML_URL is ready."
