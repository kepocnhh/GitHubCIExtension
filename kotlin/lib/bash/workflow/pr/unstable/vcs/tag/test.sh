#!/bin/bash

echo "Workflow pull request unstable VCS tag test..."

VERSION_NAME=$(ex/util/jqx -sfs assemble/project/common.json .version.name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
TAG="${VERSION_NAME}-UNSTABLE"

CODE=0
ex/vcs/tag/test.sh "$TAG"; CODE=$?
if test $CODE -ne 0; then
 ex/workflow/pr/unstable/vcs/tag/test/on_failed.sh; exit 11
fi

exit 0
