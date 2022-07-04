#!/bin/bash

echo "Workflow pull request snapshot VCS push..."

/bin/bash ex/vcs/pr/commit.sh || exit 11
/bin/bash ex/workflow/pr/snapshot/assemble/project/artifact.sh || exit 21
/bin/bash ex/workflow/pr/snapshot/assemble/project/documentation.sh || exit 22

VERSION_NAME=$(ex/util/jqx -sfs assemble/project/common.json .version.name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
TAG="${VERSION_NAME}-SNAPSHOT"

/bin/bash ex/vcs/documentation/push.sh "$TAG" || exit 31
/bin/bash ex/vcs/push.sh || exit 32
/bin/bash ex/assemble/vcs/commit.sh || exit 41

exit 0
