#!/bin/bash

echo "GitHub labels..."

REPOSITORY_URL=$(ex/util/jqx -sfs assemble/vcs/repository.json .url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
REPOSITORY_NAME=$(ex/util/jqx -sfs assemble/vcs/repository.json .name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

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
