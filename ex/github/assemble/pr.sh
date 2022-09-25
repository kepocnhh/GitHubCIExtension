#!/bin/bash

echo "Assemble github pull request..."

REPOSITORY_URL=$(ex/util/jqx -sfs assemble/vcs/repository.json .url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

. ex/util/require PR_NUMBER

CODE=0
CODE=$(curl -s -w %{http_code} -o assemble/vcs/pr${PR_NUMBER}.json \
 "$REPOSITORY_URL/pulls/$PR_NUMBER")
if test $CODE -ne 200; then
 echo "Get pull request #$PR_NUMBER error!"
 echo "Request error with response code $CODE!"
 exit 21
fi

PR_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/pr${PR_NUMBER}.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

echo "The pull request $PR_HTML_URL is ready."
