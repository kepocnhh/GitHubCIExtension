#!/bin/bash

echo "Workflow pull request unstable VCS push..."

/bin/bash ex/vcs/pr/commit.sh || exit 12
/bin/bash ex/workflow/pr/unstable/assemble/project/artifact.sh || exit 13
/bin/bash ex/vcs/push.sh || exit 14
/bin/bash ex/assemble/vcs/commit.sh || exit 15

exit 0
