#!/bin/bash

echo "Workflow pull request unstable start..."

mkdir -p assemble/vcs
/bin/bash ex/assemble/vcs/repository.sh || exit 11
/bin/bash ex/assemble/vcs/worker.sh || exit 12
/bin/bash ex/assemble/vcs/pr.sh || exit 13
/bin/bash ex/assemble/vcs/pr/commit.sh || exit 13

/bin/bash ex/vcs/pr/merge.sh || exit 21

mkdir -p assemble/project
/bin/bash ex/project/prepare.sh || exit 31
/bin/bash ex/assemble/project/common.sh || exit 32

/bin/bash ex/workflow/pr/unstable/vcs/tag/test.sh || exit 41
/bin/bash ex/workflow/pr/unstable/vcs/push.sh || exit 42
/bin/bash ex/workflow/pr/unstable/vcs/release.sh || exit 43
/bin/bash ex/vcs/pr/check_state.sh "closed" || exit 44 # todo

/bin/bash ex/workflow/pr/unstable/on_success.sh || exit 91

echo "Workflow pull request unstable finish."

exit 0
