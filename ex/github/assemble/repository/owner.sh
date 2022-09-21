#!/bin/bash

echo "Assemble VCS repository owner..."

REPOSITORY_OWNER_URL=$(ex/util/jqx -sfs assemble/vcs/repository.json .owner.url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

mkdir -p assemble/vcs/repository || exit 1 # todo

CODE=0
CODE=$(curl -w %{http_code} -o assemble/vcs/repository/owner.json $REPOSITORY_OWNER_URL)
if test $CODE -ne 200; then
 echo "Get repository owner $REPOSITORY_OWNER_URL error!"
 echo "Request error with response code $CODE!"
 exit 11
fi

REPOSITORY_OWNER_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/repository/owner.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

echo "The repository owner $REPOSITORY_OWNER_HTML_URL is ready."
