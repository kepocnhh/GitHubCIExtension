#!/bin/bash

echo "Workflow pull request unstable VCS push..."

ex/github/pr/commit.sh || exit 12
ci/workflow/pr/unstable/assemble/project/artifact.sh || exit 13
ex/vcs/push.sh || exit 14
ex/assemble/vcs/commit.sh || exit 15
