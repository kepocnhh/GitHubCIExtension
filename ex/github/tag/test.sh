#!/bin/bash

echo "GitHub tag test..."

. ex/util/args/require $# 1

TAG="$1"

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .url REPOSITORY_URL \
 -sfs .html_url REPOSITORY_HTML_URL

. ex/util/require VCS_DOMAIN REPOSITORY_OWNER REPOSITORY_NAME TAG

CODE=0
CODE=$(curl -s -w %{http_code} -o /tmp/tag.json "$REPOSITORY_URL/git/refs/tags/$TAG")
case $CODE in
 404) . ex/util/success "The tag \"$TAG\" does not exist yet in ${REPOSITORY_HTML_URL}.";;
 200) true;; # ignored
 *) echo "Get tag \"$TAG\" info error!"
  . ex/util/throw 31 "Request error with response code $CODE!";;
esac

TYPE="$(jq -Mcer type /tmp/tag.json)" \
 || . ex/util/throw 101 "Illegal state!"
case $TYPE in
 object)
  . ex/util/json -f /tmp/tag.json -sfs .ref REF
  [ "$REF" == "refs/tags/$TAG" ] && . ex/util/throw 41 "The tag \"$TAG\" already exists!"
  exit 42;;
 array)
  REFS=($(jq -Mcer ".[].ref" /tmp/tag.json)) \
   || . ex/util/throw 102 "Illegal state!"
  SIZE=${#REFS[*]}
  for ((REF_INDEX = 0; REF_INDEX < SIZE; REF_INDEX++)); do
   REF="${ARRAY[$REF_INDEX]}"
   [ "$REF" == "refs/tags/$TAG" ] && . ex/util/throw 51 "The tag \"$TAG\" already exists!"
  done; exit 0;;
 *) . ex/util/throw 61 "The type \"$TYPE\" is not supported!";;
esac

. ex/util/throw 71 "Illegal state!"
