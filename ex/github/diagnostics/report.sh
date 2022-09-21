#!/bin/bash

echo "VCS diagnostics report..."

. ex/util/require VCS_PAT

WORKER_NAME=$(ex/util/jqx -sfs assemble/vcs/worker.json .name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
WORKER_VCS_EMAIL=$(ex/util/jqx -sfs assemble/vcs/worker.json .vcs_email) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

REPOSITORY=pages/diagnostics/report
mkdir -p $REPOSITORY || exit 1 # todo
. ex/util/assert -d $REPOSITORY

REPOSITORY_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/repository.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

git -C $REPOSITORY init \
 && git -C $REPOSITORY remote add origin \
  "${REPOSITORY_HTML_URL//'://'/"://${VCS_PAT}@"}.git" \
 && git -C $REPOSITORY fetch --depth=1 origin gh-pages \
 && git -C $REPOSITORY checkout gh-pages \
 || . ex/util/throw 11 "Git checkout error!"

CI_BUILD_NUMBER=$(ex/util/jqx -si assemble/vcs/actions/run.json .run_number) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

RELATIVE_PATH=$CI_BUILD_NUMBER/diagnostics/report
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
 && git -C $REPOSITORY tag "diagnostics/report/$CI_BUILD_NUMBER" \
 || . ex/util/throw 42 "Git commit error!"

git -C $REPOSITORY push \
 && git -C $REPOSITORY push --tag \
 || . ex/util/throw 43 "Git push error!"
