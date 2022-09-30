#!/bin/bash

echo "GitHub pull request commit..."

. ex/util/json -f assemble/vcs/worker.json \
 -sfs .name WORKER_NAME \
 -sfs .vcs_email WORKER_VCS_EMAIL

. ex/util/require PR_NUMBER

. ex/util/json -f assemble/vcs/pr${PR_NUMBER}.json \
 -sfs .head.sha GIT_COMMIT_SRC \
 -sfs .base.sha GIT_COMMIT_DST

. ex/util/json -f assemble/vcs/actions/run.json \
 -si .run_number CI_BUILD_NUMBER

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

MESSAGE="Merge ${GIT_COMMIT_SRC::7} -> ${GIT_COMMIT_DST::7} by CI build #${CI_BUILD_NUMBER}."
git -C $REPOSITORY commit -m "$MESSAGE" \
 || . ex/util/throw 41 "Git commit error!"
