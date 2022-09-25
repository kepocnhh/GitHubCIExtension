#!/bin/bash

echo "Workflow pull request staging task management..."

mkdir -p assemble/github

. ex/util/require GITHUB_RUN_NUMBER GITHUB_RUN_ID PR_NUMBER \
 LABEL_ID_SNAPSHOT LABEL_ID_STAGING

GIT_COMMIT_DST=$(ex/util/jqx -sfs assemble/vcs/pr${PR_NUMBER}.json .base.sha) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
GIT_COMMIT_SRC=$(ex/util/jqx -sfs assemble/vcs/pr${PR_NUMBER}.json .head.sha) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

ex/github/commit/compare.sh "$GIT_COMMIT_DST" "$GIT_COMMIT_SRC" \
 || . ex/util/throw 11 "Illegal state!"

FILE="assemble/github/commit_compare_${GIT_COMMIT_DST::7}_${GIT_COMMIT_SRC::7}.json"

SIZE=$(jq -e ".commits|length" "$FILE") || exit 1 # todo
REGEX="(^|\s)fix iss/\K[^\W|$]+"
ISSUES=()
for ((i=0; i<SIZE; i++)); do
 it=$(ex/util/jqx -sfs "$FILE" ".commits[$i].commit.message") \
  || . ex/util/throw $? "$(cat /tmp/jqx.o)"
 ISSUES+=($(echo "$it" | grep -Po "$REGEX" | grep -Po "\d+"))
done

. ci/workflow/pr/staging/tag.sh

ex/github/labels.sh || exit 32
SIZE=${#ISSUES[*]}
echo "[]" > assemble/github/fixed.json
ISSUES=($(printf "%s\n" "${ISSUES[@]}" | sort -u))
SIZE=${#ISSUES[*]}
LABEL_ID_TARGET="$LABEL_ID_STAGING"
LABEL_TARGET="$(jq ".[]|select(.id==$LABEL_ID_TARGET)" assemble/github/labels.json)"
LABEL_NAME_TARGET="$(echo "$LABEL_TARGET" | jq -r .name)"

REPOSITORY_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/repository.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

CI_BUILD_NUMBER=$(ex/util/jqx -si assemble/vcs/actions/run.json .run_number) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
CI_BUILD_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/actions/run.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

TAG_URL="$REPOSITORY_HTML_URL/releases/tag/$TAG"
MESSAGE="Marked as \`$LABEL_NAME_TARGET\` in [$TAG]($TAG_URL) by CI build [#$CI_BUILD_NUMBER]($CI_BUILD_HTML_URL)."

exit 1 # todo

for ((i=0; i<SIZE; i++)); do
 ci/workflow/pr/staging/task/fix.sh "${ISSUES[$i]}" "$MESSAGE" || exit 1 # todo
done

exit 1 # todo

ci/workflow/pr/release/note/html.sh "$TAG" || exit 1 # todo
ex/vcs/release/note.sh "$TAG" || exit 1 # todo
