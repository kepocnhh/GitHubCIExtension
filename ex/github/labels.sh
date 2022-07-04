#!/bin/bash

echo "GitHub labels..."

. ex/util/require VCS_DOMAIN REPOSITORY_OWNER REPOSITORY_NAME

CODE=$(curl -w %{http_code} -o assemble/github/labels.json \
 "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/labels")
if test $CODE -ne 200; then
 echo "GitHub $REPOSITORY_OWNER/$REPOSITORY_NAME labels error!"
 echo "Request error with response code $CODE!"
 exit 12
fi

LABELS_LENGTH="$(jq length assemble/github/labels.json)" || exit 1 # todo

echo "$LABELS_LENGTH labels are ready."

exit 0
