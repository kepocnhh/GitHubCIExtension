#!/bin/bash

echo "GitHub compare..."

. ex/util/args/require $# 2

GIT_COMMIT_BASE="$1"
GIT_COMMIT_HEAD="$2"

. ex/util/require VCS_DOMAIN REPOSITORY_OWNER REPOSITORY_NAME GIT_COMMIT_BASE GIT_COMMIT_HEAD

FILE="assemble/github/commit_compare_${GIT_COMMIT_BASE::7}_${GIT_COMMIT_HEAD::7}.json"
CODE=$(curl -w %{http_code} -o "$FILE" \
 "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/compare/${GIT_COMMIT_BASE}...${GIT_COMMIT_HEAD}")
if test $CODE -ne 200; then
 echo "GitHub compare ${GIT_COMMIT_BASE}...${GIT_COMMIT_HEAD} error!"
 echo "Request error with response code $CODE!"
 exit 11
fi

COMPARE_HTML_URL=$(ex/util/jqx -sfs "$FILE" .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

echo "The compare $COMPARE_HTML_URL is ready."

exit 0
