#!/bin/bash

echo "GitHub issue comment..."

. ex/util/args/require $# 2

ISSUE_NUMBER="$1"
MESSAGE="$2"

. ex/util/require ISSUE_NUMBER MESSAGE

REPOSITORY_URL=$(ex/util/jqx -sfs assemble/vcs/repository.json .url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

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

COMMENT_HTML_URL=$(ex/util/jqx -sfs /tmp/comment.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

echo "The comment $COMMENT_HTML_URL is ready."
