#!/bin/bash

echo "GitHub pull request check state..."

. ex/util/args/require $# 1

EXPECTED_STATE="$1"

. ex/util/require PR_NUMBER EXPECTED_STATE

REPOSITORY_URL=$(ex/util/jqx -sfs assemble/vcs/repository.json .url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

CODE=0
CODE=$(curl -w %{http_code} -o assemble/vcs/pr${PR_NUMBER}.json \
 "$REPOSITORY_URL/pulls/$PR_NUMBER")
if test $CODE -ne 200; then
 echo "Get pull request #$PR_NUMBER error!"
 echo "Request error with response code $CODE!"
 exit 21
fi

ACTUAL_STATE=$(ex/util/jqx -sfs assemble/vcs/pr${PR_NUMBER}.json .state) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

. ex/util/assert -eq EXPECTED_STATE ACTUAL_STATE
