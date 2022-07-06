#!/bin/bash

echo "GitHub issue comment..."

. ex/util/args/require $# 2

ISSUE_NUMBER="$1"
MESSAGE="$2"

. ex/util/require VCS_DOMAIN REPOSITORY_OWNER REPOSITORY_NAME ISSUE_NUMBER MESSAGE

MESSAGE=${MESSAGE//\"/\\\"}
CODE=$(curl -w %{http_code} -o /tmp/comment.json -X POST \
 "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/issues/$ISSUE_NUMBER/comments" \
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

exit 0
