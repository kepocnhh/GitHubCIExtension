#!/bin/bash

echo "Workflow pull request staging verify..."

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
 /bin/bash ex/workflow/pr/staging/verify/on_failed.sh \
  || . ex/util/throw 12 "On failed unexpected error!"
 exit 31
fi

exit 0
