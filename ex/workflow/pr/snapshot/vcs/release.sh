#!/bin/bash

echo "Workflow pull request snapshot VCS release..."

. ex/util/require REPOSITORY_OWNER REPOSITORY_NAME GITHUB_RUN_NUMBER GITHUB_RUN_ID MAVEN_GROUP_ID MAVEN_ARTIFACT_ID

VERSION_NAME=$(ex/util/jqx -sfs assemble/project/common.json .version.name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
TAG="${VERSION_NAME}-SNAPSHOT"

GIT_COMMIT_SHA=$(ex/util/jqx -sfs assemble/vcs/commit.json .sha) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
BODY="$(echo "{}" | jq -Mc ".name=\"$TAG\"")"
BODY="$(echo "$BODY" | jq -Mc ".tag_name=\"$TAG\"")"
BODY="$(echo "$BODY" | jq -Mc ".target_commitish=\"$GIT_COMMIT_SHA\"")"
REPOSITORY_URL=https://github.com/$REPOSITORY_OWNER/$REPOSITORY_NAME
MESSAGE="CI build [#$GITHUB_RUN_NUMBER]($REPOSITORY_URL/actions/runs/$GITHUB_RUN_ID)"

MAVEN_URL="https://s01.oss.sonatype.org/content/repositories/snapshots"
MESSAGE="$MESSAGE\n - maven [snapshot](${MAVEN_URL}/${MAVEN_GROUP_ID//.//}/${MAVEN_ARTIFACT_ID}/${TAG})"

PAGES_URL="https://${REPOSITORY_OWNER}.github.io/$REPOSITORY_NAME"
DOCUMENTATION_URL="$PAGES_URL/build/$GITHUB_RUN_NUMBER/$GITHUB_RUN_ID/documentation/$TAG/index.html"
MESSAGE="$MESSAGE\n - documentation [here]($DOCUMENTATION_URL)"

RELEASE_NOTE_URL="$PAGES_URL/build/$GITHUB_RUN_NUMBER/$GITHUB_RUN_ID/release/note/index.html"
MESSAGE="$MESSAGE\n - release [note]($RELEASE_NOTE_URL)"
BODY="$(echo "$BODY" | jq -Mc ".body=\"$MESSAGE\"")"
BODY="$(echo "$BODY" | jq -Mc ".draft=false")"
BODY="$(echo "$BODY" | jq -Mc ".prerelease=true")"
mkdir -p assemble/github
ex/github/release.sh "$BODY" || exit 16

ARTIFACTS="[]"
ARTIFACT_NAME="${REPOSITORY_NAME}-${TAG}.jar"
ARTIFACT="$(echo "{}" | jq -Mc ".name=\"$ARTIFACT_NAME\"")"
ARTIFACT="$(echo "$ARTIFACT" | jq -Mc ".label=\"$ARTIFACT_NAME\"")"
ARTIFACT="$(echo "$ARTIFACT" | jq -Mc ".path=\"assemble/project/artifact/$ARTIFACT_NAME\"")"
ARTIFACTS="$(echo "$ARTIFACTS" | jq -Mc ".+=[$ARTIFACT]")"
ARTIFACT_NAME="${REPOSITORY_NAME}-${TAG}-sources.jar"
ARTIFACT="$(echo "{}" | jq -Mc ".name=\"$ARTIFACT_NAME\"")"
ARTIFACT="$(echo "$ARTIFACT" | jq -Mc ".label=\"$ARTIFACT_NAME\"")"
ARTIFACT="$(echo "$ARTIFACT" | jq -Mc ".path=\"assemble/project/artifact/$ARTIFACT_NAME\"")"
ARTIFACTS="$(echo "$ARTIFACTS" | jq -Mc ".+=[$ARTIFACT]")"
ARTIFACT_NAME="${REPOSITORY_NAME}-${TAG}.pom"
ARTIFACT="$(echo "{}" | jq -Mc ".name=\"$ARTIFACT_NAME\"")"
ARTIFACT="$(echo "$ARTIFACT" | jq -Mc ".label=\"$ARTIFACT_NAME\"")"
ARTIFACT="$(echo "$ARTIFACT" | jq -Mc ".path=\"assemble/project/artifact/$ARTIFACT_NAME\"")"
ARTIFACTS="$(echo "$ARTIFACTS" | jq -Mc ".+=[$ARTIFACT]")"

ex/github/release/upload/artifact.sh "$ARTIFACTS" || exit 17

exit 0
