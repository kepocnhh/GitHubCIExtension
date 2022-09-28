#!/bin/bash

echo "Workflow pull request snapshot check start..."

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

ex/android/app/project/verify/pre.sh \
 || . ex/util/throw 11 "Pre verify unexpected error!"

JSON_PATH=$REPOSITORY/buildSrc/src/main/resources/json
ex/android/app/project/verify/common.sh \
 "$JSON_PATH/verify/common.json" \
 "$JSON_PATH/verify/info.json" \
 && ex/android/app/project/verify/unit_test.sh \
 && exit 0

mkdir -p diagnostics
echo "{}" > diagnostics/summary.json
ex/android/app/project/diagnostics/common.sh \
 "$JSON_PATH/verify/common.json" \
 "$JSON_PATH/verify/info.json" \
 && ex/android/app/project/diagnostics/unit_test.sh \
 && ex/github/diagnostics/report.sh \
 || . ex/util/throw 21 "Diagnostics unexpected error!"

ci/workflow/pr/snapshot/check/on_failed.sh \
 || . ex/util/throw 22 "On failed unexpected error!"

exit 31
