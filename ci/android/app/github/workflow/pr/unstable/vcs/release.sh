#!/bin/bash

echo "Workflow pull request unstable VCS release..."

. ci/workflow/pr/unstable/tag.sh
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
BODY="{}"
. ex/util/jqm BODY \
 ".name=\"$TAG\"" \
 ".tag_name=\"$TAG\"" \
 ".target_commitish=\"$GIT_COMMIT_SHA\"" \
 ".body=\"CI build [#$CI_BUILD_NUMBER]($CI_BUILD_HTML_URL)\"" \
 ".draft=false" \
 ".prerelease=true"
mkdir -p assemble/github
ex/github/release.sh "$BODY" || exit 11

ex/android/app/project/sign/artifact/verify.sh "$TAG" || exit 21

ASSETS="[]"
for it in \
 "${REPOSITORY_NAME}-${ARTIFACT_VERSION}.apk" \
 "${REPOSITORY_NAME}-${ARTIFACT_VERSION}.apk.sig"; do
 ASSET="{}"
 . ex/util/jqm ASSET \
  ".name=\"$it\"" \
  ".label=\"$it\"" \
  ".path=\"assemble/project/artifact/$it\""
 . ex/util/jqm ASSETS ".+=[$ASSET]"
done

ex/github/release/upload/asset.sh "$ASSETS" || exit 31
