#!/bin/bash

echo "Workflow pull request assemble vcs..."

mkdir -p assemble/vcs
/bin/bash ex/assemble/vcs/repository.sh || exit 11
/bin/bash ex/assemble/vcs/worker.sh || exit 12
/bin/bash ex/assemble/vcs/pr.sh || exit 13
/bin/bash ex/assemble/vcs/pr/commit.sh || exit 14

exit 0
