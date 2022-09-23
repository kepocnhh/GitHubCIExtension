#!/bin/bash

echo "Assemble github pull request commit..."

REPOSITORY_URL=$(ex/util/jqx -sfs assemble/vcs/repository.json .url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

. ex/util/require PR_NUMBER

GIT_COMMIT_SRC=$(ex/util/jqx -sfs assemble/vcs/pr${PR_NUMBER}.json .head.sha) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

CODE=0
CODE=$(curl -s -w %{http_code} -o assemble/vcs/commit.src.json \
 "$REPOSITORY_URL/commits/$GIT_COMMIT_SRC")
if test $CODE -ne 200; then
 echo "Get commit source $GIT_COMMIT_SRC info error!"
 echo "Request error with response code $CODE!"
 exit 11
fi

COMMIT_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/commit.src.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

echo "The commit source $COMMIT_HTML_URL is ready."

AUTHOR_LOGIN=$(ex/util/jqx -sfs assemble/vcs/commit.src.json .author.login) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

mkdir -p assemble/vcs/commit || exit 1 # todo
CODE=0
CODE=$(curl -s -w %{http_code} -o assemble/vcs/commit/author.src.json \
 "$VCS_DOMAIN/users/$AUTHOR_LOGIN")
if test $CODE -ne 200; then
 echo "Get author source $AUTHOR_LOGIN info error!"
 echo "Request error with response code $CODE!"
 exit 12
fi

AUTHOR_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/commit/author.src.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

echo "The author source $AUTHOR_HTML_URL is ready."

GIT_COMMIT_DST=$(ex/util/jqx -sfs assemble/vcs/pr${PR_NUMBER}.json .base.sha) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

CODE=0
CODE=$(curl -s -w %{http_code} -o assemble/vcs/commit.dst.json \
 "$REPOSITORY_URL/commits/$GIT_COMMIT_DST")
if test $CODE -ne 200; then
 echo "Get commit destination $GIT_COMMIT_DST info error!"
 echo "Request error with response code $CODE!"
 exit 21
fi

COMMIT_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/commit.dst.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

echo "The commit destination $COMMIT_HTML_URL is ready."

AUTHOR_LOGIN=$(ex/util/jqx -sfs assemble/vcs/commit.dst.json .author.login) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

mkdir -p assemble/vcs/commit || exit 1 # todo
CODE=0
CODE=$(curl -s -w %{http_code} -o assemble/vcs/commit/author.dst.json \
 "$VCS_DOMAIN/users/$AUTHOR_LOGIN")
if test $CODE -ne 200; then
 echo "Get author destination $AUTHOR_LOGIN info error!"
 echo "Request error with response code $CODE!"
 exit 22
fi

AUTHOR_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/commit/author.dst.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

echo "The author destination $AUTHOR_HTML_URL is ready."
