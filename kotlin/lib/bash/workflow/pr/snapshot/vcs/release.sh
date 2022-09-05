#!/bin/bash

echo "Workflow pull request snapshot VCS release..."

. ex/workflow/pr/snapshot/tag.sh

. ex/util/require REPOSITORY_OWNER REPOSITORY_NAME GITHUB_RUN_NUMBER GITHUB_RUN_ID TAG \
 MAVEN_GROUP_ID MAVEN_ARTIFACT_ID

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

ex/project/sign/artifact/verify.sh "$TAG" || exit 21

ARTIFACTS="[]"
for it in \
 "${REPOSITORY_NAME}-${TAG}.jar" \
 "${REPOSITORY_NAME}-${TAG}.jar.sig" \
 "${REPOSITORY_NAME}-${TAG}-sources.jar" \
 "${REPOSITORY_NAME}-${TAG}.pom"; do
 ARTIFACT="$(echo "{}" | jq -Mc ".name=\"$it\"")"
 ARTIFACT="$(echo "$ARTIFACT" | jq -Mc ".label=\"$it\"")"
 ARTIFACT="$(echo "$ARTIFACT" | jq -Mc ".path=\"assemble/project/artifact/$it\"")"
 ARTIFACTS="$(echo "$ARTIFACTS" | jq -Mc ".+=[$ARTIFACT]")"
done

ex/github/release/upload/artifact.sh "$ARTIFACTS" || exit 17
