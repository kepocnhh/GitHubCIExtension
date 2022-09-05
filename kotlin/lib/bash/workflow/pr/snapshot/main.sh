#!/bin/bash

echo "Workflow pull request snapshot start..."

ex/workflow/pr/assemble/vcs.sh || exit 11

ex/vcs/pr/merge.sh || exit 21

mkdir -p assemble/project
ex/project/prepare.sh || exit 31
ex/project/sign/prepare.sh || exit 32
ex/assemble/project/common.sh || exit 33

ex/workflow/pr/snapshot/vcs/tag/test.sh || exit 81
ex/workflow/pr/snapshot/maven/tag/test.sh || exit 82
ex/workflow/pr/snapshot/verify.sh || exit 51 # todo
ex/workflow/pr/snapshot/task/management.sh || exit 61 # todo

ex/workflow/pr/snapshot/vcs/push.sh || exit 42
ex/workflow/pr/snapshot/maven/release.sh || exit 43
ex/workflow/pr/snapshot/vcs/release.sh || exit 44
ex/workflow/pr/check_state.sh "closed" || exit 71
ex/workflow/pr/snapshot/on_success.sh || exit 91

echo "Workflow pull request snapshot finish."
