#!/bin/bash

echo "Workflow pull request snapshot verify..."

ex/project/verify/pre.sh \
 || . ex/util/throw 21 "Pre verify unexpected error!"

JSON_PATH=repository/buildSrc/src/main/resources/json
ex/project/verify/common.sh \
 "$JSON_PATH/verify/common.json" \
 "$JSON_PATH/verify/info.json" \
 "$JSON_PATH/verify/documentation.json" \
 && ex/project/verify/unit_test.sh \
 && exit 0

mkdir -p diagnostics
echo "{}" > diagnostics/summary.json
ex/project/diagnostics/common.sh \
 "$JSON_PATH/verify/common.json" \
 "$JSON_PATH/verify/info.json" \
 "$JSON_PATH/verify/documentation.json" \
 && ex/project/diagnostics/unit_test.sh \
 && ex/vcs/diagnostics/report.sh \
 || . ex/util/throw 11 "Diagnostics unexpected error!"
ex/workflow/pr/snapshot/verify/on_failed.sh \
 || . ex/util/throw 12 "On failed unexpected error!"
exit 31
