#!/bin/bash

echo "Workflow pull request staging start..."

/bin/bash ex/workflow/pr/assemble/vcs.sh || exit 11

/bin/bash ex/vcs/pr/merge.sh || exit 21

mkdir -p assemble/project
/bin/bash ex/project/prepare.sh || exit 31
/bin/bash ex/assemble/project/common.sh || exit 32

/bin/bash ex/workflow/pr/staging/vcs/tag/test.sh || exit 41
/bin/bash ex/workflow/pr/staging/verify.sh || exit 51 # todo
/bin/bash ex/workflow/pr/staging/task/management.sh || exit 61 # todo
/bin/bash ex/workflow/pr/staging/vcs/push.sh || exit 42
/bin/bash ex/workflow/pr/check_state.sh "closed" || exit 44

/bin/bash ex/workflow/pr/staging/on_success.sh || exit 91

echo "Workflow pull request staging finish."

exit 0
