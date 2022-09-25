#!/bin/bash

echo "Workflow pull request unstable VCS push..."

ex/github/pr/commit.sh || exit 11
ci/workflow/pr/unstable/assemble/project/artifact.sh || exit 12
ci/workflow/pr/vcs/push.sh || exit 13
ex/github/assemble/commit.sh || exit 14
