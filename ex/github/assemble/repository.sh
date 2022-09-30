#!/bin/bash

echo "Assemble VCS repository..."

. ex/util/json -f assemble/vcs/actions/run.json \
 -sfs .repository.url REPOSITORY_URL \
 -sfs .repository.name REPOSITORY_NAME

CODE=0
CODE=$(curl -s -w %{http_code} -o assemble/vcs/repository.json $REPOSITORY_URL)
if test $CODE -ne 200; then
 echo "Get repository $REPOSITORY_NAME error!"
 echo "Request error with response code $CODE!"
 exit 11
fi

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .html_url REPOSITORY_HTML_URL

echo "The repository $REPOSITORY_HTML_URL is ready."
