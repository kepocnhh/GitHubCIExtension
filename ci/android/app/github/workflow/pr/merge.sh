#!/bin/bash

echo "Workflow pr merge start..."

. ex/util/require PR_NUMBER

. ex/util/json -f assemble/vcs/worker.json \
 -sfs .name WORKER_NAME \
 -sfs .vcs_email WORKER_VCS_EMAIL

. ex/util/json -f assemble/vcs/pr${PR_NUMBER}.json \
 -sfs .base.ref GIT_BRANCH_DST \
 -sfs .head.sha GIT_COMMIT_SRC

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
