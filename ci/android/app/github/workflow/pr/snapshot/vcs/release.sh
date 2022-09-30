#!/bin/bash

echo "Workflow pull request snapshot VCS release..."

. ci/workflow/pr/snapshot/tag.sh

. ex/util/require TAG

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .name REPOSITORY_NAME \
 -sfs .url REPOSITORY_URL

. ex/util/json -f assemble/vcs/actions/run.json \
 -si .run_number CI_BUILD_NUMBER \
 -sfs .html_url CI_BUILD_HTML_URL

. ex/util/json -f assemble/vcs/commit.json \
 -sfs .sha GIT_COMMIT_SHA

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
