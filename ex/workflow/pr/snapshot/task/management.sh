#!/bin/bash

echo "Workflow pull request snapshot task management..."

mkdir -p assemble/github

. ex/util/require REPOSITORY_OWNER REPOSITORY_NAME GITHUB_RUN_NUMBER GITHUB_RUN_ID PR_NUMBER \
 LABEL_ID_SNAPSHOT LABEL_ID_STAGING

GIT_COMMIT_DST=$(ex/util/jqx -sfs assemble/vcs/pr${PR_NUMBER}.json .base.sha) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
GIT_COMMIT_SRC=$(ex/util/jqx -sfs assemble/vcs/pr${PR_NUMBER}.json .head.sha) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

/bin/bash ex/github/commit/compare.sh "$GIT_COMMIT_DST" "$GIT_COMMIT_SRC" || exit 11 # todo

FILE="assemble/github/commit_compare_${GIT_COMMIT_DST::7}_${GIT_COMMIT_SRC::7}.json"

SIZE=$(jq -e ".commits|length" "$FILE") || exit 1 # todo
REGEX="(^|\s)fix iss/\K[^\W|$]+"
ISSUES=()
for ((i=0; i<SIZE; i++)); do
 it=$(ex/util/jqx -sfs "$FILE" ".commits[$i].commit.message") \
  || . ex/util/throw $? "$(cat /tmp/jqx.o)"
 ISSUES+=($(echo "$it" | grep -Po "$REGEX" | grep -Po "\d+"))
done

VERSION_NAME=$(ex/util/jqx -sfs assemble/project/common.json .version.name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
TAG="${VERSION_NAME}-SNAPSHOT"

/bin/bash ex/github/labels.sh || exit 32
SIZE=${#ISSUES[*]}
echo "[]" > assemble/github/fixed.json
ISSUES=($(printf "%s\n" "${ISSUES[@]}" | sort -u))
SIZE=${#ISSUES[*]}
LABEL_ID_TARGET="$LABEL_ID_SNAPSHOT"
LABEL_TARGET="$(jq ".[]|select(.id==$LABEL_ID_TARGET)" assemble/github/labels.json)"
LABEL_NAME_TARGET="$(echo "$LABEL_TARGET" | jq -r .name)"
REPOSITORY_URL=https://github.com/$REPOSITORY_OWNER/$REPOSITORY_NAME
TAG_URL="$REPOSITORY_URL/releases/tag/$TAG"
BUILD_URL="$REPOSITORY_URL/actions/runs/$GITHUB_RUN_ID"
MESSAGE="Marked as \`$LABEL_NAME_TARGET\` in [$TAG]($TAG_URL) by CI build [#$GITHUB_RUN_NUMBER]($BUILD_URL)."
for ((i=0; i<SIZE; i++)); do
 /bin/bash ex/workflow/pr/snapshot/task/fix.sh "${ISSUES[$i]}" "$MESSAGE" || exit 1 # todo
done

/bin/bash ex/workflow/pr/release/note/html.sh "$TAG" || exit 1 # todo
/bin/bash ex/vcs/release/note.sh "$TAG" || exit 1 # todo

exit 0
