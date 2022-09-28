#!/bin/bash

echo "VCS diagnostics report..."

. ex/util/require VCS_PAT

. ex/util/jq/write WORKER_NAME -sfs assemble/vcs/worker.json .name
. ex/util/jq/write WORKER_VCS_EMAIL -sfs assemble/vcs/worker.json .vcs_email

REPOSITORY=pages/diagnostics/report
mkdir -p $REPOSITORY || exit 1 # todo
. ex/util/assert -d $REPOSITORY

. ex/util/jq/write REPOSITORY_HTML_URL -sfs assemble/vcs/repository.json .html_url

git -C $REPOSITORY init \
 && git -C $REPOSITORY remote add origin \
  "${REPOSITORY_HTML_URL//'://'/"://${VCS_PAT}@"}.git" \
 && git -C $REPOSITORY fetch --depth=1 origin gh-pages \
 && git -C $REPOSITORY checkout gh-pages \
 || . ex/util/throw 11 "Git checkout error!"

. ex/util/jq/write CI_BUILD_ID -si assemble/vcs/actions/run.json .id
. ex/util/jq/write CI_BUILD_NUMBER -si assemble/vcs/actions/run.json .run_number

RELATIVE_PATH=$CI_BUILD_NUMBER/$CI_BUILD_ID/diagnostics/report
mkdir -p $REPOSITORY/build/$RELATIVE_PATH \
 && cp -r diagnostics/report/* $REPOSITORY/build/$RELATIVE_PATH || exit 1 # todo

COMMIT_MESSAGE="CI build #$CI_BUILD_NUMBER | $WORKER_NAME added diagnostics report"

TYPES="$(jq -Mcer "keys" diagnostics/summary.json)" || exit 1 # todo
if test "$TYPES" == "[]"; then
 echo "Diagnostics should have determined the cause of the failure!"; exit 1
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
