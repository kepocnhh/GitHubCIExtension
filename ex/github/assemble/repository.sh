#!/bin/bash

echo "Assemble VCS repository..."

REPOSITORY_URL=$(ex/util/jqx -sfs assemble/vcs/actions/run.json .repository.url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

REPOSITORY_NAME=$(ex/util/jqx -sfs assemble/vcs/actions/run.json .repository.name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

CODE=0
CODE=$(curl -s -w %{http_code} -o assemble/vcs/repository.json $REPOSITORY_URL)
if test $CODE -ne 200; then
 echo "Get repository $REPOSITORY_NAME error!"
 echo "Request error with response code $CODE!"
 exit 11
fi

REPOSITORY_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/repository.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

echo "The repository $REPOSITORY_HTML_URL is ready."
