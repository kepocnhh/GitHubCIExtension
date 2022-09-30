#!/bin/bash

echo "Assemble VCS actions run..."

. ex/util/require VCS_DOMAIN REPOSITORY_OWNER REPOSITORY_NAME CI_BUILD_ID

mkdir -p assemble/vcs/actions \
 || . ex/util/throw 11 "Illegal state!"

CODE=0
CODE=$(curl -s -w %{http_code} -o assemble/vcs/actions/run.json \
 "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/actions/runs/$CI_BUILD_ID")
if test $CODE -ne 200; then
 echo "Get actions run $CI_BUILD_ID error!"
 echo "Request error with response code $CODE!"
 exit 11
fi

. ex/util/json -f assemble/vcs/actions/run.json \
 -sfs .html_url RUN_HTML_URL

echo "The actions run $RUN_HTML_URL is ready."
