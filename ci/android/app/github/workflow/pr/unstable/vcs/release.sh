#!/bin/bash

echo "Workflow pull request unstable VCS release..."

. ex/workflow/pr/unstable/tag.sh
. ex/android/app/project/version.sh

. ex/util/require ARTIFACT_VERSION TAG

REPOSITORY_NAME=$(ex/util/jqx -sfs assemble/vcs/repository.json .name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
REPOSITORY_URL=$(ex/util/jqx -sfs assemble/vcs/repository.json .url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

CI_BUILD_NUMBER=$(ex/util/jqx -si assemble/vcs/actions/run.json .run_number) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
CI_BUILD_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/actions/run.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

GIT_COMMIT_SHA=$(ex/util/jqx -sfs assemble/vcs/commit.json .sha) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
BODY="$(echo "{}" | jq -Mc ".name=\"$TAG\"")"
BODY="$(echo "$BODY" | jq -Mc ".tag_name=\"$TAG\"")"
BODY="$(echo "$BODY" | jq -Mc ".target_commitish=\"$GIT_COMMIT_SHA\"")"
BODY="$(echo "$BODY" | jq -Mc ".body=\"CI build [#$CI_BUILD_NUMBER]($CI_BUILD_HTML_URL)\"")"
BODY="$(echo "$BODY" | jq -Mc ".draft=false")"
BODY="$(echo "$BODY" | jq -Mc ".prerelease=true")"
mkdir -p assemble/github
ex/github/release.sh "$BODY" || exit 11

ex/android/app/project/sign/artifact/verify.sh "$TAG" || exit 21

ASSETS="[]"
for it in \
 "${REPOSITORY_NAME}-${ARTIFACT_VERSION}.apk" \
 "${REPOSITORY_NAME}-${ARTIFACT_VERSION}.apk.sig"; do
 ASSET="$(echo "{}" | jq -Mc ".name=\"$it\"")"
 ASSET="$(echo "$ASSET" | jq -Mc ".label=\"$it\"")"
 ASSET="$(echo "$ASSET" | jq -Mc ".path=\"assemble/project/artifact/$it\"")"
 ASSETS="$(echo "$ASSETS" | jq -Mc ".+=[$ASSET]")"
done

ex/github/release/upload/asset.sh "$ASSETS" || exit 31
