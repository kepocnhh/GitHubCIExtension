#!/bin/bash

echo "Workflow verify start..."

mkdir -p assemble/vcs
ex/assemble/vcs/repository.sh || exit 11
ex/assemble/vcs/worker.sh || exit 12
ex/assemble/vcs/commit.sh || exit 13

mkdir -p assemble/project
ex/project/prepare.sh || exit 21
ex/assemble/project/common.sh || exit 22

ex/project/verify/pre.sh \
 || . ex/util/throw 31 "Pre verify unexpected error!"

CODE=0

JSON_PATH=repository/buildSrc/src/main/resources/json
ex/project/verify/common.sh \
 "$JSON_PATH/verify/common.json" \
 "$JSON_PATH/verify/info.json" \
 "$JSON_PATH/verify/documentation.json" \
 && ex/project/verify/unit_test.sh; CODE=$?
if test $CODE -ne 0; then
 mkdir -p diagnostics
 echo "{}" > diagnostics/summary.json
 ex/project/diagnostics/common.sh \
  "$JSON_PATH/verify/common.json" \
  "$JSON_PATH/verify/info.json" \
  "$JSON_PATH/verify/documentation.json" \
  && ex/project/diagnostics/unit_test.sh \
  && ex/vcs/diagnostics/report.sh \
  || . ex/util/throw 41 "Diagnostics unexpected error!"
 ex/workflow/verify/on_failed.sh \
  || . ex/util/throw 42 "On failed unexpected error!"
 exit 43
fi

ex/workflow/verify/on_success.sh \
 || . ex/util/throw 51 "On success unexpected error!"

echo "Workflow verify finish."
