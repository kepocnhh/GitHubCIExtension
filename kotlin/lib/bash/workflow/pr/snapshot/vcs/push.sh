#!/bin/bash

echo "Workflow pull request snapshot VCS push..."

ex/vcs/pr/commit.sh || exit 11
ex/workflow/pr/snapshot/assemble/project/artifact.sh || exit 21
ex/workflow/pr/snapshot/assemble/project/documentation.sh || exit 22

. ex/workflow/pr/snapshot/tag.sh

ex/vcs/documentation/push.sh "$TAG" || exit 31
ex/vcs/push.sh || exit 32
ex/assemble/vcs/commit.sh || exit 41

exit 0
