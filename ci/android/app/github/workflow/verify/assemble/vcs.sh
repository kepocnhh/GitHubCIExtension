#!/bin/bash

echo "Workflow verify assemble vcs start..."

mkdir -p assemble/vcs || exit 11
ex/github/assemble/actions/run.sh || exit 21
ex/github/assemble/repository.sh || exit 31
ex/github/assemble/repository/owner.sh || exit 32
ex/github/assemble/worker.sh || exit 41
ex/github/assemble/commit.sh || exit 42
