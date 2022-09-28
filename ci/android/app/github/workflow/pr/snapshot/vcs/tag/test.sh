#!/bin/bash

echo "Workflow pull request snapshot VCS tag test..."

. ci/workflow/pr/snapshot/tag.sh

CODE=0
ex/github/tag/test.sh "$TAG"; CODE=$?
if test $CODE -ne 0; then
 ci/workflow/pr/snapshot/vcs/tag/test/on_failed.sh; exit 11
fi
