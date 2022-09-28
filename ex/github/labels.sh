#!/bin/bash

echo "GitHub labels..."

. ex/util/jq/write REPOSITORY_URL -sfs assemble/vcs/repository.json .url

CODE=$(curl -w %{http_code} -o assemble/github/labels.json \
 "$REPOSITORY_URL/labels")
if test $CODE -ne 200; then
 . ex/util/jq/write REPOSITORY_NAME -sfs assemble/vcs/repository.json .name
 echo "GitHub  repository $REPOSITORY_NAME labels error!"
 echo "Request error with response code $CODE!"
 exit 11
fi

LABELS_LENGTH="$(jq length assemble/github/labels.json)" \
 || . ex/util/throw 12 "Illegal state!"

echo "$LABELS_LENGTH labels are ready."
