#!/bin/bash

echo "VCS release note..."

. ex/util/args/require $# 1

TAG="$1"

. ex/util/require VCS_PAT REPOSITORY_OWNER REPOSITORY_NAME GITHUB_RUN_NUMBER GITHUB_RUN_ID TAG

WORKER_NAME=$(ex/util/jqx -sfs assemble/vcs/worker.json .name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
WORKER_VCS_EMAIL=$(ex/util/jqx -sfs assemble/vcs/worker.json .vcs_email) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

REPOSITORY=pages/release/note
mkdir -p $REPOSITORY || exit 1 # todo

git -C $REPOSITORY init \
 && git -C $REPOSITORY remote add origin \
  https://$VCS_PAT@github.com/$REPOSITORY_OWNER/$REPOSITORY_NAME.git \
 && git -C $REPOSITORY fetch --depth=1 origin gh-pages \
 && git -C $REPOSITORY checkout gh-pages \
 || . ex/util/throw 11 "Git checkout error!"

RELATIVE_PATH=$GITHUB_RUN_NUMBER/$GITHUB_RUN_ID/release/note
mkdir -p $REPOSITORY/build/$RELATIVE_PATH || exit 1 # todo
cp assemble/github/release_note.html $REPOSITORY/build/$RELATIVE_PATH/index.html || exit 1 # todo

COMMIT_MESSAGE="CI build #$GITHUB_RUN_NUMBER | $WORKER_NAME added release note $TAG"

git -C $REPOSITORY config user.name "$WORKER_NAME" \
 && git -C $REPOSITORY config user.email "$WORKER_VCS_EMAIL" \
 || . ex/util/throw 41 "Git config error!"

git -C $REPOSITORY add --all . \
 && git -C $REPOSITORY commit -m "$COMMIT_MESSAGE" \
 && git -C $REPOSITORY tag "release/note/$GITHUB_RUN_NUMBER/$GITHUB_RUN_ID" \
 || . ex/util/throw 42 "Git commit error!"

git -C $REPOSITORY push \
 && git -C $REPOSITORY push --tag \
 || . ex/util/throw 43 "Git push error!"

exit 0
