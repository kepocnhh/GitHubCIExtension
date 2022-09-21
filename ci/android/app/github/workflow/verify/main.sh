#!/bin/bash

echo "Workflow verify start..."

ci/workflow/verify/assemble/vcs.sh || exit 11
ci/workflow/verify/assemble/project/prepare.sh || exit 12
ci/workflow/verify/check.sh || exit 13
ci/workflow/verify/on_success.sh || exit 14
