#!/bin/bash

echo "Workflow pr staging assemble vcs start..."

mkdir -p assemble/vcs || exit 11

ex/util/run/pipeline \
 ex/github/assemble/actions/run.sh \
 ex/github/assemble/repository.sh \
 ex/github/assemble/repository/owner.sh \
 ex/github/assemble/repository/pages.sh || exit 21

ex/util/run/pipeline \
 ex/github/assemble/worker.sh \
 ex/github/assemble/pr.sh \
 ex/github/assemble/pr/commit.sh || exit 22
