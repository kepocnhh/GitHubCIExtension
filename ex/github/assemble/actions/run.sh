#!/bin/bash

echo "Assemble VCS actions run..."

. ex/util/require REPOSITORY_OWNER REPOSITORY_NAME VCS_DOMAIN CI_BUILD_ID

mkdir -p assemble/vcs/actions || exit 1 # todo

CODE=0
CODE=$(curl -w %{http_code} -o assemble/vcs/actions/run.json \
 "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/actions/runs/$CI_BUILD_ID")
if test $CODE -ne 200; then
 echo "Get actions run $CI_BUILD_ID error!"
 echo "Request error with response code $CODE!"
 exit 11
fi

RUN_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/actions/run.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

echo "The actions run $RUN_HTML_URL is ready."
