#!/bin/bash

echo "GitHub pull request commit..."

WORKER_NAME=$(ex/util/jqx -sfs assemble/vcs/worker.json .name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
WORKER_VCS_EMAIL=$(ex/util/jqx -sfs assemble/vcs/worker.json .vcs_email) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

. ex/util/require PR_NUMBER

GIT_COMMIT_SRC=$(ex/util/jqx -sfs assemble/vcs/pr${PR_NUMBER}.json ".head.sha") \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
GIT_COMMIT_DST=$(ex/util/jqx -sfs assemble/vcs/pr${PR_NUMBER}.json ".base.sha") \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

CI_BUILD_NUMBER=$(ex/util/jqx -si assemble/vcs/actions/run.json .run_number) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

MESSAGE="Merge ${GIT_COMMIT_SRC::7} -> ${GIT_COMMIT_DST::7} by CI build #${CI_BUILD_NUMBER}."
git -C $REPOSITORY commit -m "$MESSAGE" \
 || . ex/util/throw 41 "Git commit error!"
