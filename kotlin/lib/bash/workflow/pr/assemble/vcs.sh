#!/bin/bash

echo "Workflow pull request assemble vcs..."

mkdir -p assemble/vcs
ex/assemble/vcs/repository.sh || exit 11
ex/assemble/vcs/worker.sh || exit 12
ex/assemble/vcs/pr.sh || exit 13
ex/assemble/vcs/pr/commit.sh || exit 14

exit 0
