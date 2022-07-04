#!/bin/bash

echo "VCS pull request check state..."

. ex/util/args/require $# 1

EXPECTED_STATE="$1"

. ex/util/require VCS_DOMAIN REPOSITORY_OWNER REPOSITORY_NAME PR_NUMBER EXPECTED_STATE

CODE=0
CODE=$(curl -w %{http_code} -o assemble/vcs/pr${PR_NUMBER}.json \
 "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/pulls/$PR_NUMBER")
if test $CODE -ne 200; then
 echo "Get pull request #$PR_NUMBER error!"
 echo "Request error with response code $CODE!"
 exit 21
fi

ACTUAL_STATE=$(ex/util/jqx -sfs assemble/vcs/pr${PR_NUMBER}.json .state) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

. ex/util/assert -eq EXPECTED_STATE ACTUAL_STATE

exit 0
