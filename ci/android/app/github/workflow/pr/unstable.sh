#!/bin/bash

echo "Workflow pull request unstable start..."

WORKFLOW=ci/workflow/pr/unstable

ex/util/run/pipeline \
 $WORKFLOW/assemble/vcs.sh \
 ci/workflow/pr/merge.sh \
 $WORKFLOW/assemble/project/prepare.sh || exit 21

ex/util/run/pipeline \
 $WORKFLOW/vcs/tag/test.sh \
 $WORKFLOW/vcs/push.sh \
 $WORKFLOW/vcs/release.sh \
 && ci/workflow/pr/check_state.sh "closed" || exit 22

$WORKFLOW/on_success.sh || exit 23
