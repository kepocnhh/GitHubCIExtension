#!/bin/bash

echo "Workflow pull request unstable start..."

mkdir -p assemble/vcs
ex/assemble/vcs/repository.sh || exit 11
ex/assemble/vcs/worker.sh || exit 12
ex/assemble/vcs/pr.sh || exit 13
ex/assemble/vcs/pr/commit.sh || exit 13

ex/vcs/pr/merge.sh || exit 21

mkdir -p assemble/project
ex/project/prepare.sh || exit 31
ex/project/sign/prepare.sh || exit 32
ex/assemble/project/common.sh || exit 33

ex/workflow/pr/unstable/vcs/tag/test.sh || exit 41
ex/workflow/pr/unstable/vcs/push.sh || exit 42
ex/workflow/pr/unstable/vcs/release.sh || exit 43
ex/vcs/pr/check_state.sh "closed" || exit 44 # todo

ex/workflow/pr/unstable/on_success.sh || exit 91

echo "Workflow pull request unstable finish."
