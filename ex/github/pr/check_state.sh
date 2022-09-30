#!/bin/bash

echo "GitHub pull request check state..."

. ex/util/args/require $# 1

EXPECTED_STATE="$1"

. ex/util/require PR_NUMBER EXPECTED_STATE

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .url REPOSITORY_URL

CODE=0
CODE=$(curl -w %{http_code} -o assemble/vcs/pr${PR_NUMBER}.json \
 "$REPOSITORY_URL/pulls/$PR_NUMBER")
if test $CODE -ne 200; then
 echo "Get pull request #$PR_NUMBER error!"
 echo "Request error with response code $CODE!"
 exit 21
fi

. ex/util/json -f assemble/vcs/pr${PR_NUMBER}.json \
 -sfs .state ACTUAL_STATE

. ex/util/assert -eq EXPECTED_STATE ACTUAL_STATE
