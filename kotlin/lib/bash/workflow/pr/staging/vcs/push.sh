#!/bin/bash

echo "Workflow pull request staging VCS push..."

ex/vcs/pr/commit.sh || exit 12

. ex/workflow/pr/staging/tag.sh

ex/vcs/tag.sh "$TAG" || exit 13
ex/vcs/push.sh || exit 14
ex/vcs/tag/push.sh || exit 15
ex/assemble/vcs/commit.sh || exit 21

exit 0
