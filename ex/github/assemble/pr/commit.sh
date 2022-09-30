#!/bin/bash

echo "Assemble github pull request commit..."

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .url REPOSITORY_URL

. ex/util/require PR_NUMBER

. ex/util/json -f assemble/vcs/pr${PR_NUMBER}.json \
 -sfs .head.sha GIT_COMMIT_SRC \
 -sfs .base.sha GIT_COMMIT_DST

mkdir -p assemble/vcs/commit \
 || . ex/util/throw 11 "Illegal state!"

CODE=0
CODE=$(curl -s -w %{http_code} -o assemble/vcs/commit.src.json \
 "$REPOSITORY_URL/commits/$GIT_COMMIT_SRC")
if test $CODE -ne 200; then
 echo "Get commit source $GIT_COMMIT_SRC info error!"
 echo "Request error with response code $CODE!"
 exit 11
fi

. ex/util/json -f assemble/vcs/commit.src.json \
 -sfs .html_url COMMIT_HTML_URL \
 -sfs .author.login AUTHOR_LOGIN

echo "The commit source $COMMIT_HTML_URL is ready."

CODE=0
CODE=$(curl -s -w %{http_code} -o assemble/vcs/commit/author.src.json \
 "$VCS_DOMAIN/users/$AUTHOR_LOGIN")
if test $CODE -ne 200; then
 echo "Get author source $AUTHOR_LOGIN info error!"
 echo "Request error with response code $CODE!"
 exit 12
fi

. ex/util/json -f assemble/vcs/commit/author.src.json \
 -sfs .html_url AUTHOR_HTML_URL

echo "The author source $AUTHOR_HTML_URL is ready."

CODE=0
CODE=$(curl -s -w %{http_code} -o assemble/vcs/commit.dst.json \
 "$REPOSITORY_URL/commits/$GIT_COMMIT_DST")
if test $CODE -ne 200; then
 echo "Get commit destination $GIT_COMMIT_DST info error!"
 echo "Request error with response code $CODE!"
 exit 21
fi

. ex/util/json -f assemble/vcs/commit.dst.json \
 -sfs .html_url COMMIT_HTML_URL \
 -sfs .author.login AUTHOR_LOGIN

echo "The commit destination $COMMIT_HTML_URL is ready."

CODE=0
CODE=$(curl -s -w %{http_code} -o assemble/vcs/commit/author.dst.json \
 "$VCS_DOMAIN/users/$AUTHOR_LOGIN")
if test $CODE -ne 200; then
 echo "Get author destination $AUTHOR_LOGIN info error!"
 echo "Request error with response code $CODE!"
 exit 22
fi

. ex/util/json -f assemble/vcs/commit/author.dst.json \
 -sfs .html_url AUTHOR_HTML_URL

echo "The author destination $AUTHOR_HTML_URL is ready."
