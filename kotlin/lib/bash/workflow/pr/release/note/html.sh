#!/bin/bash

echo "Workflow pull request release note html..."

. ex/util/args/require $# 1

TAG="$1"

. ex/util/require REPOSITORY_OWNER REPOSITORY_NAME TAG

REPOSITORY_URL=https://github.com/$REPOSITORY_OWNER/$REPOSITORY_NAME
TAG_URL="$REPOSITORY_URL/releases/tag/$TAG"
RELEASE_NOTE="<html>
<h1>Release note <a href="$TAG_URL">$TAG</a></h1>"
SIZE=$(jq -e "length" assemble/github/fixed.json) || exit 1 # todo
if test $SIZE -eq 0; then
 RELEASE_NOTE="$RELEASE_NOTE
<ul><li>not a single issue has been resolved</li></ul>"
else
 RELEASE_NOTE="$RELEASE_NOTE
<h3>Fixed:</h3>"
 FILE="assemble/github/fixed.json"
 for ((i=0; i<SIZE; i++)); do
  ISSUE_NUMBER=$(ex/util/jqx -si "$FILE" ".[$i].number") \
   || . ex/util/throw $? "$(cat /tmp/jqx.o)"
  ISSUE_TITLE=$(ex/util/jqx -sfs "$FILE" ".[$i].title") \
   || . ex/util/throw $? "$(cat /tmp/jqx.o)"
  ISSUE_HTML_URL=$(ex/util/jqx -sfs "$FILE" ".[$i].html_url") \
   || . ex/util/throw $? "$(cat /tmp/jqx.o)"
  RELEASE_NOTE="$RELEASE_NOTE
<ul><li><a href="$ISSUE_HTML_URL">#$ISSUE_NUMBER</a> $ISSUE_TITLE</li></ul>"
 done
fi
RELEASE_NOTE="$RELEASE_NOTE
</html>"

echo "$RELEASE_NOTE" > assemble/github/release_note.html

exit 0
