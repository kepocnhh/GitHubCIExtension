#!/bin/bash

echo "Workflow pull request snapshot verify..."

ex/project/verify/pre.sh \
 || . ex/util/throw 21 "Pre verify unexpected error!"

CODE=0

JSON_PATH=repository/buildSrc/src/main/resources/json
ex/project/verify/common.sh "$JSON_PATH/verify.json" \
 && ex/project/verify/common.sh "$JSON_PATH/verify/documentation.json" \
 && ex/project/verify/unit_test.sh; CODE=$?
if test $CODE -ne 0; then
 mkdir -p diagnostics
 echo "{}" > diagnostics/summary.json
 ex/project/diagnostics/common.sh "$JSON_PATH/verify.json" \
  && ex/project/diagnostics/common.sh "$JSON_PATH/verify/documentation.json" \
  && ex/project/diagnostics/unit_test.sh \
  && ex/vcs/diagnostics/report.sh \
  || . ex/util/throw 11 "Diagnostics unexpected error!"
 ex/workflow/pr/snapshot/verify/on_failed.sh \
  || . ex/util/throw 12 "On failed unexpected error!"
 exit 31
fi

exit 0
