#!/bin/bash

echo "VCS diagnostics report..."

. ex/util/require VCS_PAT

. ex/util/json -f assemble/vcs/worker.json \
 -sfs .name WORKER_NAME \
 -sfs .html_url WORKER_HTML_URL

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .html_url REPOSITORY_HTML_URL

REPOSITORY=pages/diagnostics/report
mkdir -p $REPOSITORY \
 || . ex/util/throw 11 "Illegal state!"
. ex/util/assert -d $REPOSITORY

git -C $REPOSITORY init \
 && git -C $REPOSITORY remote add origin \
  "${REPOSITORY_HTML_URL//'://'/"://${VCS_PAT}@"}.git" \
 && git -C $REPOSITORY fetch --depth=1 origin gh-pages \
 && git -C $REPOSITORY checkout gh-pages \
 || . ex/util/throw 21 "Git checkout error!"

. ex/util/json -f assemble/vcs/actions/run.json \
 -si .id CI_BUILD_ID \
 -si .run_number CI_BUILD_NUMBER

RELATIVE_PATH=$CI_BUILD_NUMBER/$CI_BUILD_ID/diagnostics/report
mkdir -p $REPOSITORY/build/$RELATIVE_PATH \
 && cp -r diagnostics/report/* $REPOSITORY/build/$RELATIVE_PATH \
 || . ex/util/throw 22 "Illegal state!"

COMMIT_MESSAGE="CI build #$CI_BUILD_NUMBER | $WORKER_NAME added diagnostics report"

TYPES="$(jq -Mcer "keys" diagnostics/summary.json)" \
 || . ex/util/throw 23 "Illegal state!"
if test "$TYPES" == "[]"; then
 . ex/util/throw 31 "Diagnostics should have determined the cause of the failure!"
fi
COMMIT_MESSAGE="${COMMIT_MESSAGE} of ${TYPES} issues."

git -C $REPOSITORY config user.name "$WORKER_NAME" \
 && git -C $REPOSITORY config user.email "$WORKER_VCS_EMAIL" \
 || . ex/util/throw 41 "Git config error!"

git -C $REPOSITORY add --all . \
 && git -C $REPOSITORY commit -m "$COMMIT_MESSAGE" \
 && git -C $REPOSITORY tag "diagnostics/report/$CI_BUILD_NUMBER/$CI_BUILD_ID" \
 || . ex/util/throw 42 "Git commit error!"

git -C $REPOSITORY push \
 && git -C $REPOSITORY push --tag \
 || . ex/util/throw 43 "Git push error!"
