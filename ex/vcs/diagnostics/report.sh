#!/bin/bash

echo "VCS diagnostics report..."

. ex/util/require VCS_PAT REPOSITORY_OWNER REPOSITORY_NAME GITHUB_RUN_NUMBER GITHUB_RUN_ID

WORKER_NAME=$(ex/util/jqx -sfs assemble/vcs/worker.json .name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
WORKER_VCS_EMAIL=$(ex/util/jqx -sfs assemble/vcs/worker.json .vcs_email) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

REPOSITORY=pages/diagnostics/report
mkdir -p $REPOSITORY || exit 1 # todo
. ex/util/assert -d $REPOSITORY

git -C $REPOSITORY init \
 && git -C $REPOSITORY remote add origin \
  https://$VCS_PAT@github.com/$REPOSITORY_OWNER/$REPOSITORY_NAME.git \
 && git -C $REPOSITORY fetch --depth=1 origin gh-pages \
 && git -C $REPOSITORY checkout gh-pages \
 || . ex/util/throw 11 "Git checkout error!"

RELATIVE_PATH=$GITHUB_RUN_NUMBER/$GITHUB_RUN_ID/diagnostics/report
mkdir -p $REPOSITORY/build/$RELATIVE_PATH || exit 1 # todo
cp -r diagnostics/report/* $REPOSITORY/build/$RELATIVE_PATH || exit 1 # todo

COMMIT_MESSAGE="CI build #$GITHUB_RUN_NUMBER | $WORKER_NAME added diagnostics report"

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
 && git -C $REPOSITORY tag "diagnostics/report/$GITHUB_RUN_NUMBER/$GITHUB_RUN_ID" \
 || . ex/util/throw 42 "Git commit error!"

git -C $REPOSITORY push \
 && git -C $REPOSITORY push --tag \
 || . ex/util/throw 43 "Git push error!"

exit 0
