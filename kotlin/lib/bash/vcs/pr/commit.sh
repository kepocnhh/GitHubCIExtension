#!/bin/bash

echo "VCS pull request commit..."

WORKER_NAME=$(ex/util/jqx -sfs assemble/vcs/worker.json .name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
WORKER_VCS_EMAIL=$(ex/util/jqx -sfs assemble/vcs/worker.json .vcs_email) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

GIT_COMMIT_SRC=$(ex/util/jqx -sfs assemble/vcs/pr${PR_NUMBER}.json ".head.sha") \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
GIT_COMMIT_DST=$(ex/util/jqx -sfs assemble/vcs/pr${PR_NUMBER}.json ".base.sha") \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

. ex/util/require PR_NUMBER GITHUB_RUN_NUMBER

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

MESSAGE="Merge ${GIT_COMMIT_SRC::7} -> ${GIT_COMMIT_DST::7} by CI build #${GITHUB_RUN_NUMBER}."
git -C $REPOSITORY commit -m "$MESSAGE" \
 || . ex/util/throw 41 "Git commit error!"

exit 0
