#!/bin/bash

echo "Assemble VCS repository owner..."

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .owner.url REPOSITORY_OWNER_URL

mkdir -p assemble/vcs/repository \
 || . ex/util/throw 11 "Illegal state!"

CODE=0
CODE=$(curl -s -w %{http_code} -o assemble/vcs/repository/owner.json $REPOSITORY_OWNER_URL)
if test $CODE -ne 200; then
 echo "Get repository owner $REPOSITORY_OWNER_URL error!"
 echo "Request error with response code $CODE!"
 exit 11
fi

. ex/util/json -f assemble/vcs/repository/owner.json \
 -sfs .html_url REPOSITORY_OWNER_HTML_URL

echo "The repository owner $REPOSITORY_OWNER_HTML_URL is ready."
