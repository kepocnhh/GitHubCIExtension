#!/bin/bash

echo "Workflow pull request staging VCS tag test..."

. ci/workflow/pr/staging/tag.sh

CODE=0
ex/github/tag/test.sh "$TAG"; CODE=$?
if test $CODE -ne 0; then
 ci/workflow/pr/staging/vcs/tag/test/on_failed.sh; exit 11
fi
