#!/bin/bash

echo "Workflow pr merge start..."

. ex/util/require PR_NUMBER

WORKER_NAME=$(ex/util/jqx -sfs assemble/vcs/worker.json .name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
WORKER_VCS_EMAIL=$(ex/util/jqx -sfs assemble/vcs/worker.json .vcs_email) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
GIT_BRANCH_DST=$(ex/util/jqx -sfs assemble/vcs/pr${PR_NUMBER}.json .base.ref) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
GIT_COMMIT_SRC=$(ex/util/jqx -sfs assemble/vcs/pr${PR_NUMBER}.json .head.sha) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

git -C $REPOSITORY config user.name "$WORKER_NAME" \
 && git -C $REPOSITORY config user.email "$WORKER_VCS_EMAIL" \
 || . ex/util/throw 41 "Git config error!"

echo "Fetch ${GIT_BRANCH_DST}..."
git -C $REPOSITORY fetch origin $GIT_BRANCH_DST \
 || . ex/util/throw 42 "Git fetch \"$GIT_BRANCH_DST\" error!"

echo "Checkout ${GIT_BRANCH_DST}..."
git -C $REPOSITORY checkout $GIT_BRANCH_DST \
 || . ex/util/throw 43 "Git checkout to \"$GIT_BRANCH_DST\" error!"

echo "Merge ${GIT_COMMIT_SRC::7} -> \"${GIT_BRANCH_DST}\"..."
git -C $REPOSITORY merge --no-ff --no-commit $GIT_COMMIT_SRC \
 || . ex/util/throw 44 "Merge ${GIT_COMMIT_SRC::7} -> \"$GIT_BRANCH_DST\" error!"
