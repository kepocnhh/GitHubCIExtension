#!/bin/bash

echo "GitHub labels..."

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .url REPOSITORY_URL \
 -sfs .name REPOSITORY_NAME

CODE=$(curl -w %{http_code} -o assemble/github/labels.json \
 "$REPOSITORY_URL/labels")
if test $CODE -ne 200; then
 echo "GitHub  repository $REPOSITORY_NAME labels error!"
 echo "Request error with response code $CODE!"
 exit 11
fi

LABELS_LENGTH="$(jq length assemble/github/labels.json)" \
 || . ex/util/throw 12 "Illegal state!"

echo "$LABELS_LENGTH labels are ready."
