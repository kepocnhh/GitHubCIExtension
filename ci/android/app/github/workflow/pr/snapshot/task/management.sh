#!/bin/bash

echo "Workflow pull request snapshot task management..."

mkdir -p assemble/github

. ex/util/require PR_NUMBER LABEL_ID_SNAPSHOT

. ex/util/jq/write GIT_COMMIT_DST -sfs assemble/vcs/pr${PR_NUMBER}.json .base.sha
. ex/util/jq/write GIT_COMMIT_SRC -sfs assemble/vcs/pr${PR_NUMBER}.json .head.sha

ex/github/commit/compare.sh "$GIT_COMMIT_DST" "$GIT_COMMIT_SRC" \
 || . ex/util/throw 11 "Illegal state!"

FILE="assemble/github/commit_compare_${GIT_COMMIT_DST::7}_${GIT_COMMIT_SRC::7}.json"

SIZE=$(jq -e ".commits|length" "$FILE") \
 || . ex/util/throw 12 "Illegal state!"
REGEX="(^|\s)fix iss/\K[^\W|$]+"
ISSUES=()
for ((COMMIT_INDEX=0; COMMIT_INDEX<SIZE; COMMIT_INDEX++)); do
 . ex/util/jq/write COMMIT_MESSAGE -sfs "$FILE" ".commits[$COMMIT_INDEX].commit.message"
 ISSUES+=($(echo "$COMMIT_MESSAGE" | grep -Po "$REGEX" | grep -Po "\d+"))
done

. ci/workflow/pr/snapshot/tag.sh

ex/github/labels.sh \
 || . ex/util/throw 13 "Illegal state!"
SIZE=${#ISSUES[*]}
echo "[]" > assemble/github/fixed.json
ISSUES=($(printf "%s\n" "${ISSUES[@]}" | sort -u))
SIZE=${#ISSUES[*]}
LABEL_ID_TARGET="$LABEL_ID_SNAPSHOT"
LABEL_TARGET="$(jq ".[]|select(.id==$LABEL_ID_TARGET)" assemble/github/labels.json)"
LABEL_NAME_TARGET="$(echo "$LABEL_TARGET" | jq -r .name)"

. ex/util/jq/write REPOSITORY_HTML_URL -sfs assemble/vcs/repository.json .html_url

. ex/util/jq/write CI_BUILD_NUMBER -si assemble/vcs/actions/run.json .run_number
. ex/util/jq/write CI_BUILD_HTML_URL -sfs assemble/vcs/actions/run.json .html_url

TAG_URL="$REPOSITORY_HTML_URL/releases/tag/$TAG"
MESSAGE="Marked as \`$LABEL_NAME_TARGET\` in [$TAG]($TAG_URL) by CI build [#$CI_BUILD_NUMBER]($CI_BUILD_HTML_URL)."

for ((ISSUE_INDEX=0; ISSUE_INDEX<SIZE; ISSUE_INDEX++)); do
 ci/workflow/pr/snapshot/task/fix.sh "${ISSUES[$ISSUE_INDEX]}" "$MESSAGE" \
  || . ex/util/throw $((100 + $ISSUE_INDEX)) "Illegal state!"
done

ci/workflow/pr/release/note/markdown.sh "$TAG" \
 || . ex/util/throw 21 "Illegal state!"

ex/github/release/note.sh "$TAG" \
 || . ex/util/throw 22 "Illegal state!"
