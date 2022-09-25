#!/bin/bash

echo "GitHub release note..."

. ex/util/args/require $# 1

TAG="$1"

. ex/util/require VCS_DOMAIN VCS_PAT TAG

. ex/util/jq/write WORKER_NAME -sfs assemble/vcs/worker.json .name
. ex/util/jq/write WORKER_VCS_EMAIL -sfs assemble/vcs/worker.json .vcs_email
. ex/util/jq/write REPOSITORY_HTML_URL -sfs assemble/vcs/repository.json .html_url

REPOSITORY=pages/release/note
mkdir -p $REPOSITORY || . ex/util/throw 11 "Illegal state!"

git -C $REPOSITORY init \
 && git -C $REPOSITORY remote add origin \
  "${REPOSITORY_HTML_URL//'://'/"://${VCS_PAT}@"}.git" \
 && git -C $REPOSITORY fetch --depth=1 origin gh-pages \
 && git -C $REPOSITORY checkout gh-pages \
 || . ex/util/throw 21 "Git checkout error!"

. ex/util/jq/write CI_BUILD_NUMBER -si assemble/vcs/actions/run.json .run_number

. ex/util/assert -f assemble/github/release_note.md

TEXT="$(cat assemble/github/release_note.md)"
TEXT="${TEXT//$'\n'/\\n}"
BODY="{}"
. ex/util/jqm BODY \
 ".text=\"$TEXT\"" \
 ".mode=\"markdown\""
CODE=0
CODE=$(curl -s -w %{http_code} -X POST -o assemble/github/release_note.html \
 "$VCS_DOMAIN/markdown" \
 -d "$BODY")
if test $CODE -ne 200; then
 echo "Markdown to html error!"
 echo "Request error with response code $CODE!"
 exit 31
fi

RELATIVE_PATH=$CI_BUILD_NUMBER/release/note
mkdir -p $REPOSITORY/build/$RELATIVE_PATH \
 && cp assemble/github/release_note.html $REPOSITORY/build/$RELATIVE_PATH/index.html \
 || . ex/util/throw 22 "Illegal state!"

COMMIT_MESSAGE="CI build #$CI_BUILD_NUMBER | $WORKER_NAME added release note $TAG"

git -C $REPOSITORY config user.name "$WORKER_NAME" \
 && git -C $REPOSITORY config user.email "$WORKER_VCS_EMAIL" \
 || . ex/util/throw 41 "Git config error!"

git -C $REPOSITORY add --all . \
 && git -C $REPOSITORY commit -m "$COMMIT_MESSAGE" \
 && git -C $REPOSITORY tag "release/note/$CI_BUILD_NUMBER" \
 || . ex/util/throw 42 "Git commit error!"

git -C $REPOSITORY push \
 && git -C $REPOSITORY push --tag \
 || . ex/util/throw 43 "Git push error!"
