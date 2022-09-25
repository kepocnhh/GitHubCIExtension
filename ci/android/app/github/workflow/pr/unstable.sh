#!/bin/bash

echo "Workflow pull request unstable start..."

ci/workflow/pr/unstable/assemble/vcs.sh || exit 11
ci/workflow/pr/merge.sh || exit 12
ci/workflow/pr/unstable/assemble/project/prepare.sh || exit 13

ci/workflow/pr/unstable/vcs/tag/test.sh || exit 21
ci/workflow/pr/unstable/vcs/push.sh || exit 22
ci/workflow/pr/unstable/vcs/release.sh || exit 23
ci/workflow/pr/check_state.sh "closed" || exit 24

ci/workflow/pr/unstable/on_success.sh || exit 31
