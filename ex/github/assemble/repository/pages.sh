#!/bin/bash

echo "Assemble VCS repository owner..."

. ex/util/require VCS_PAT

REPOSITORY_URL=$(ex/util/jqx -sfs assemble/vcs/repository.json .url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

REPOSITORY_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/repository.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

mkdir -p assemble/vcs/repository || exit 1 # todo

CODE=0
CODE=$(curl -s -w %{http_code} -o assemble/vcs/repository/pages.json \
 "$REPOSITORY_URL/pages" \
 -H "Authorization: token $VCS_PAT")
if test $CODE -ne 200; then
 echo "Get pages $REPOSITORY_HTML_URL error!"
 echo "Request error with response code $CODE!"
 exit 11
fi

REPOSITORY_PAGES_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/repository/pages.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

echo "The pages $REPOSITORY_PAGES_HTML_URL is ready."
