#!/bin/bash

echo "Assemble github pull request..."

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .url REPOSITORY_URL

. ex/util/require PR_NUMBER

CODE=0
CODE=$(curl -s -w %{http_code} -o assemble/vcs/pr${PR_NUMBER}.json \
 "$REPOSITORY_URL/pulls/$PR_NUMBER")
if test $CODE -ne 200; then
 echo "Get pull request #$PR_NUMBER error!"
 echo "Request error with response code $CODE!"
 exit 21
fi

. ex/util/json -f assemble/vcs/pr${PR_NUMBER}.json \
 -sfs .html_url PR_HTML_URL

echo "The pull request $PR_HTML_URL is ready."
