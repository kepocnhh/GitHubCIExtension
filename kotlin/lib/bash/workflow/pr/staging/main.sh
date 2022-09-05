#!/bin/bash

echo "Workflow pull request staging start..."

ex/workflow/pr/assemble/vcs.sh || exit 11

ex/vcs/pr/merge.sh || exit 21

mkdir -p assemble/project
ex/project/prepare.sh || exit 31
ex/assemble/project/common.sh || exit 32

ex/workflow/pr/staging/vcs/tag/test.sh || exit 41
ex/workflow/pr/staging/verify.sh || exit 51 # todo
ex/workflow/pr/staging/task/management.sh || exit 61 # todo
ex/workflow/pr/staging/vcs/push.sh || exit 42
ex/workflow/pr/check_state.sh "closed" || exit 44

ex/workflow/pr/staging/on_success.sh || exit 91

echo "Workflow pull request staging finish."
