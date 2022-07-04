#!/bin/bash

echo "Assemble VCS pull request..."

. ex/util/require VCS_DOMAIN REPOSITORY_OWNER REPOSITORY_NAME PR_NUMBER

CODE=0
CODE=$(curl -w %{http_code} -o assemble/vcs/pr${PR_NUMBER}.json \
 "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/pulls/$PR_NUMBER")
if test $CODE -ne 200; then
 echo "Get pull request #$PR_NUMBER error!"
 echo "Request error with response code $CODE!"
 exit 21
fi

PR_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/pr${PR_NUMBER}.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

echo "The pull request $PR_HTML_URL is ready."

exit 0
