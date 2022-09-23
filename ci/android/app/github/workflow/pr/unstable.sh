#!/bin/bash

echo "Workflow pr unstable start..."

ci/workflow/pr/unstable/assemble/vcs.sh || exit 11
ex/vcs/pr/merge.sh || exit 21

ci/workflow/pr/unstable/assemble/project/prepare.sh || exit 12
ci/workflow/pr/unstable/check.sh || exit 13
ci/workflow/pr/unstable/on_success.sh || exit 14
