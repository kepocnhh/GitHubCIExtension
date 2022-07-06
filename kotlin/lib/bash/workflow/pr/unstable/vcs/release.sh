#!/bin/bash

echo "Workflow pull request unstable VCS release..."

. ex/util/require REPOSITORY_OWNER REPOSITORY_NAME GITHUB_RUN_NUMBER GITHUB_RUN_ID

. ex/workflow/pr/unstable/tag.sh

GIT_COMMIT_SHA=$(ex/util/jqx -sfs assemble/vcs/commit.json .sha) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
BODY="$(echo "{}" | jq -Mc ".name=\"$TAG\"")"
BODY="$(echo "$BODY" | jq -Mc ".tag_name=\"$TAG\"")"
BODY="$(echo "$BODY" | jq -Mc ".target_commitish=\"$GIT_COMMIT_SHA\"")"
REPOSITORY_URL=https://github.com/$REPOSITORY_OWNER/$REPOSITORY_NAME
BODY="$(echo "$BODY" | jq -Mc ".body=\"CI build [#$GITHUB_RUN_NUMBER]($REPOSITORY_URL/actions/runs/$GITHUB_RUN_ID)\"")"
BODY="$(echo "$BODY" | jq -Mc ".draft=false")"
BODY="$(echo "$BODY" | jq -Mc ".prerelease=true")"
mkdir -p assemble/github
ex/github/release.sh "$BODY" || exit 16

ARTIFACT_NAME="${REPOSITORY_NAME}-${TAG}.jar"
ARTIFACT="$(echo "{}" | jq -Mc ".name=\"$ARTIFACT_NAME\"")"
ARTIFACT="$(echo "$ARTIFACT" | jq -Mc ".label=\"$ARTIFACT_NAME\"")"
ARTIFACT="$(echo "$ARTIFACT" | jq -Mc ".path=\"assemble/project/artifact/$ARTIFACT_NAME\"")"
ARTIFACTS="$(echo "[]" | jq -Mc ".+=[$ARTIFACT]")"
ex/github/release/upload/artifact.sh "$ARTIFACTS" || exit 17

exit 0
