#!/bin/bash

echo "Workflow pull request release note markdown..."

. ex/util/args/require $# 1

TAG="$1"

. ex/util/require REPOSITORY_OWNER REPOSITORY_NAME TAG

REPOSITORY_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/repository.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

TAG_URL="$REPOSITORY_HTML_URL/releases/tag/$TAG"
RELEASE_NOTE="## Release note [$TAG]($TAG_URL)"
SIZE=$(jq -e "length" assemble/github/fixed.json) || . ex/util/throw 11 "Illegal state!"
if test $SIZE -eq 0; then
 RELEASE_NOTE="$RELEASE_NOTE
- not a single issue has been resolved"
else
 RELEASE_NOTE="$RELEASE_NOTE
### Fixed:"
 FILE="assemble/github/fixed.json"
 for ((i=0; i<SIZE; i++)); do
  ISSUE_NUMBER=$(ex/util/jqx -si "$FILE" ".[$i].number") \
   || . ex/util/throw $? "$(cat /tmp/jqx.o)"
  ISSUE_TITLE=$(ex/util/jqx -sfs "$FILE" ".[$i].title") \
   || . ex/util/throw $? "$(cat /tmp/jqx.o)"
  ISSUE_HTML_URL=$(ex/util/jqx -sfs "$FILE" ".[$i].html_url") \
   || . ex/util/throw $? "$(cat /tmp/jqx.o)"
  RELEASE_NOTE="$RELEASE_NOTE
- [#$ISSUE_NUMBER]($ISSUE_HTML_URL) $ISSUE_TITLE"
 done
fi

echo "$RELEASE_NOTE" > assemble/github/release_note.md
