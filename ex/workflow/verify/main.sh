#!/bin/bash

echo "Workflow verify start..."

mkdir -p assemble/vcs
/bin/bash ex/assemble/vcs/repository.sh || exit 11
/bin/bash ex/assemble/vcs/worker.sh || exit 12
/bin/bash ex/assemble/vcs/commit.sh || exit 13

mkdir -p assemble/project
/bin/bash ex/project/prepare.sh || exit 21
/bin/bash ex/assemble/project/common.sh || exit 22

/bin/bash ex/project/verify/pre.sh \
 || . ex/util/throw 21 "Pre verify unexpected error!"

CODE=0

JSON_PATH=repository/buildSrc/src/main/resources/json
/bin/bash ex/project/verify/common.sh "$JSON_PATH/verify.json" \
 && /bin/bash ex/project/verify/unit_test.sh; CODE=$?
if test $CODE -ne 0; then
 mkdir -p diagnostics
 echo "{}" > diagnostics/summary.json
 /bin/bash ex/project/diagnostics/common.sh "$JSON_PATH/verify.json" \
  && /bin/bash ex/project/diagnostics/unit_test.sh \
  && /bin/bash ex/vcs/diagnostics/report.sh \
  || . ex/util/throw 11 "Diagnostics unexpected error!"
 /bin/bash ex/workflow/verify/on_failed.sh \
  || . ex/util/throw 12 "On failed unexpected error!"
 exit 31
fi

/bin/bash ex/workflow/verify/on_success.sh || exit 41

echo "Workflow verify finish."

exit 0
