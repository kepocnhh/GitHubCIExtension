#!/bin/bash

echo "Workflow pull request snapshot VCS release..."

. ci/workflow/pr/snapshot/tag.sh

. ex/util/require TAG

. ex/util/jq/write REPOSITORY_NAME -sfs assemble/vcs/repository.json .name
. ex/util/jq/write REPOSITORY_URL -sfs assemble/vcs/repository.json .url

. ex/util/jq/write CI_BUILD_NUMBER -si assemble/vcs/actions/run.json .run_number
. ex/util/jq/write CI_BUILD_HTML_URL -sfs assemble/vcs/actions/run.json .html_url

. ex/util/jq/write GIT_COMMIT_SHA -sfs assemble/vcs/commit.json .sha

BODY="{}"
. ex/util/jq/merge BODY \
 ".name=\"$TAG\"" \
 ".tag_name=\"$TAG\"" \
 ".target_commitish=\"$GIT_COMMIT_SHA\"" \
 ".body=\"CI build [#$CI_BUILD_NUMBER]($CI_BUILD_HTML_URL)\"" \
 ".draft=false" \
 ".prerelease=true"
mkdir -p assemble/github
ex/github/release.sh "$BODY" \
 || . ex/util/throw 21 "Illegal state!"

ex/android/app/project/sign/artifact/verify.sh "$TAG" || exit 22

ASSETS="[]"
for it in \
 "${REPOSITORY_NAME}-${TAG}.apk" \
 "${REPOSITORY_NAME}-${TAG}.apk.sig"; do
 ASSET="{}"
 . ex/util/jq/merge ASSET \
  ".name=\"$it\"" \
  ".label=\"$it\"" \
  ".path=\"assemble/project/artifact/$it\""
 . ex/util/jq/merge ASSETS ".+=[$ASSET]"
done

ex/github/release/upload/asset.sh "$ASSETS" \
 || . ex/util/throw 31 "Illegal state!"
