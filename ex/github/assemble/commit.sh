#!/bin/bash

echo "Assemble VCS commit..."

GIT_COMMIT_SHA="$(git -C repository rev-parse HEAD)" \
 || . ex/util/throw 11 "Get commit SHA error!"

. ex/util/require VCS_DOMAIN REPOSITORY_OWNER REPOSITORY_NAME GIT_COMMIT_SHA

CODE=0
CODE=$(curl -s -w %{http_code} -o assemble/vcs/commit.json \
 "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/commits/$GIT_COMMIT_SHA")
if test $CODE -ne 200; then
 echo "Get commit $GIT_COMMIT_SHA info error!"
 echo "Request error with response code $CODE!"
 exit 21
fi

. ex/util/json -f assemble/vcs/commit.json \
 -sfs .html_url COMMIT_HTML_URL \
 -sfs .author.login AUTHOR_LOGIN

echo "The commit $COMMIT_HTML_URL is ready."

mkdir -p assemble/vcs/commit || exit 1 # todo
CODE=0
CODE=$(curl -s -w %{http_code} -o assemble/vcs/commit/author.json \
 "$VCS_DOMAIN/users/$AUTHOR_LOGIN")
if test $CODE -ne 200; then
 echo "Get author info error!"
 echo "Request error with response code $CODE!"
 exit 22
fi

. ex/util/json -f assemble/vcs/commit/author.json \
 -sfs .html_url AUTHOR_HTML_URL

echo "The author $AUTHOR_HTML_URL is ready."
