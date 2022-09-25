#!/bin/bash

echo "Workflow pull request staging start..."

WORKFLOW=ci/workflow/pr/staging

ex/util/run/pipeline \
 $WORKFLOW/assemble/vcs.sh \
 ci/workflow/pr/merge.sh \
 $WORKFLOW/assemble/project/prepare.sh || exit 21

ex/util/run/pipeline \
 $WORKFLOW/vcs/tag/test.sh \
 $WORKFLOW/check.sh \
 $WORKFLOW/task/management.sh \
 $WORKFLOW/vcs/push.sh \
 && ci/workflow/pr/check_state.sh "closed" || exit 22

$WORKFLOW/on_success.sh || exit 23
