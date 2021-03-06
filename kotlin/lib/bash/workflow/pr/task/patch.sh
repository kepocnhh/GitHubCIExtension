#!/bin/bash

echo "Workflow pull request task patch..."

. ex/util/args/require $# 2

ISSUE_NUMBER="$1"
LABEL_ID_TARGET="$2"

. ex/util/require ISSUE_NUMBER

LABEL_TARGET="$(jq ".[]|select(.id==$LABEL_ID_TARGET)" assemble/github/labels.json)"
LABEL_NAME_TARGET="$(echo "$LABEL_TARGET" | jq -r .name)"

ISSUE_LABELS="$(jq .labels assemble/github/issue${ISSUE_NUMBER}.json)"
REGEX="^status/\\\\w[\\\\s\\\\w]+$"
QUERY=".[]|select(.name|test(\"$REGEX\")).id"
for it in $(echo "$ISSUE_LABELS" | jq "$QUERY"); do
 ISSUE_LABELS="$(echo "$ISSUE_LABELS" | jq ".|map(select(.id!=$it))")"
done
ISSUE_LABELS="$(echo "$ISSUE_LABELS" | jq ".+[$LABEL_TARGET]")"
ISSUE="$(echo "{}" | jq ".labels=$ISSUE_LABELS")"

ex/github/issue/patch.sh "$ISSUE_NUMBER" "$ISSUE" \
 || . ex/util/throw 33 "Issue patch unexpected error!"

exit 0
