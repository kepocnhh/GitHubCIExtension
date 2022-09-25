#!/bin/bash

echo "Workflow pr unstable assemble vcs start..."

mkdir -p assemble/vcs || exit 11
ex/github/assemble/actions/run.sh || exit 21
ex/github/assemble/repository.sh || exit 31
ex/github/assemble/repository/owner.sh || exit 32
ex/github/assemble/worker.sh || exit 41
ex/github/assemble/pr.sh || exit 42
ex/github/assemble/pr/commit.sh || exit 43
