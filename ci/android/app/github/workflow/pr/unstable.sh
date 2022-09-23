#!/bin/bash

echo "Workflow pull request unstable start..."

ci/workflow/pr/unstable/assemble/vcs.sh || exit 11
ci/workflow/pr/merge.sh || exit 12
ci/workflow/pr/unstable/assemble/project/prepare.sh || exit 13

ci/workflow/pr/unstable/vcs/tag/test.sh || exit 41
ci/workflow/pr/unstable/vcs/push.sh || exit 42
ci/workflow/pr/unstable/vcs/release.sh || exit 43
ex/vcs/pr/check_state.sh "closed" || exit 44 # todo

ci/workflow/pr/unstable/on_success.sh || exit 15
