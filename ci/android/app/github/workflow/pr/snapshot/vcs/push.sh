#!/bin/bash

echo "Workflow pull request snapshot VCS push..."

ex/github/pr/commit.sh || exit 11
ex/workflow/pr/snapshot/assemble/project/artifact.sh || exit 21

. ci/workflow/pr/snapshot/tag.sh

ci/workflow/pr/vcs/tag.sh "$TAG" || exit 12
ci/workflow/pr/vcs/push.sh || exit 13
ci/workflow/pr/vcs/tag/push.sh || exit 14
ex/github/assemble/commit.sh || exit 15
