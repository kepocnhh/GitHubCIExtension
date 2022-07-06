#!/bin/bash

echo "Assemble VCS repository..."

. ex/util/require REPOSITORY_OWNER REPOSITORY_NAME VCS_DOMAIN

CODE=0
CODE=$(curl -w %{http_code} -o assemble/vcs/repository.json \
 "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME")
if test $CODE -ne 200; then
 echo "Get repository ${GITLAB_PROJECT} error!"
 echo "Request error with response code $CODE!"
 exit 21
fi

REPOSITORY_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/repository.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

echo "The repository $REPOSITORY_HTML_URL is ready."

exit 0
