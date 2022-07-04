#!/bin/bash

echo "Workflow pull request staging VCS tag test..."

VERSION_NAME=$(ex/util/jqx -sfs assemble/project/common.json .version.name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
TAG="${VERSION_NAME}-STAGING"

CODE=0
/bin/bash ex/vcs/tag/test.sh "$TAG"; CODE=$?
if test $CODE -ne 0; then
 /bin/bash ex/workflow/pr/staging/vcs/tag/test/on_failed.sh; exit 11
fi

exit 0
