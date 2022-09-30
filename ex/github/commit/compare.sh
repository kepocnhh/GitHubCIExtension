#!/bin/bash

echo "GitHub commit compare..."

. ex/util/args/require $# 2

GIT_COMMIT_BASE="$1"
GIT_COMMIT_HEAD="$2"

. ex/util/require GIT_COMMIT_BASE GIT_COMMIT_HEAD

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .url REPOSITORY_URL

FILE="assemble/github/commit_compare_${GIT_COMMIT_BASE::7}_${GIT_COMMIT_HEAD::7}.json"
CODE=$(curl -w %{http_code} -o "$FILE" \
 "$REPOSITORY_URL/compare/${GIT_COMMIT_BASE}...${GIT_COMMIT_HEAD}")
if test $CODE -ne 200; then
 echo "GitHub compare ${GIT_COMMIT_BASE}...${GIT_COMMIT_HEAD} error!"
 echo "Request error with response code $CODE!"
 exit 11
fi

. ex/util/json -f "$FILE" \
 -sfs .html_url COMPARE_HTML_URL

echo "The compare $COMPARE_HTML_URL is ready."
