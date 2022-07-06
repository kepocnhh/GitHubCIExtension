#!/bin/bash

echo "Workflow pull request staging VCS tag test..."

. ex/workflow/pr/staging/tag.sh

CODE=0
ex/vcs/tag/test.sh "$TAG"; CODE=$?
if test $CODE -ne 0; then
 ex/workflow/pr/staging/vcs/tag/test/on_failed.sh; exit 11
fi

exit 0
