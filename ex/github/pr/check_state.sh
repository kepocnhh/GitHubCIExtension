#!/bin/bash

echo "GitHub pull request check state..."

. ex/util/args/require $# 1

EXPECTED_STATE="$1"

. ex/util/require PR_NUMBER EXPECTED_STATE

. ex/util/jq/write REPOSITORY_URL -sfs assemble/vcs/repository.json .url

CODE=0
CODE=$(curl -w %{http_code} -o assemble/vcs/pr${PR_NUMBER}.json \
 "$REPOSITORY_URL/pulls/$PR_NUMBER")
if test $CODE -ne 200; then
 echo "Get pull request #$PR_NUMBER error!"
 echo "Request error with response code $CODE!"
 exit 21
fi

. ex/util/jq/write ACTUAL_STATE -sfs assemble/vcs/pr${PR_NUMBER}.json .state

. ex/util/assert -eq EXPECTED_STATE ACTUAL_STATE
