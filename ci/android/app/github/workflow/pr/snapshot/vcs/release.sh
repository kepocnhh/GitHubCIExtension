#!/bin/bash

echo "Workflow pull request snapshot VCS release..."

. ci/workflow/pr/snapshot/tag.sh
. ex/android/app/project/version.sh

. ex/util/require ARTIFACT_VERSION TAG

. ex/util/jq/write REPOSITORY_NAME -sfs assemble/vcs/repository.json .name
. ex/util/jq/write REPOSITORY_URL -sfs assemble/vcs/repository.json .url

. ex/util/jq/write CI_BUILD_NUMBER -si assemble/vcs/actions/run.json .run_number
. ex/util/jq/write CI_BUILD_HTML_URL -sfs assemble/vcs/actions/run.json .html_url

. ex/util/jq/write GIT_COMMIT_SHA -sfs assemble/vcs/commit.json .sha

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

ex/android/app/project/sign/artifact/verify.sh "$ARTIFACT_VERSION" || exit 21

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
