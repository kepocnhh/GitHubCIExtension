#!/bin/bash

echo "GitHub tag test..."

. ex/util/args/require $# 1

TAG="$1"

REPOSITORY_URL=$(ex/util/jqx -sfs assemble/vcs/repository.json .url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

. ex/util/require VCS_DOMAIN REPOSITORY_OWNER REPOSITORY_NAME TAG

CODE=0
CODE=$(curl -s -w %{http_code} -o /tmp/tag.json "$REPOSITORY_URL/git/refs/tags/$TAG")
case $CODE in
 404)
  REPOSITORY_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/repository.json .html_url) \
   || . ex/util/throw $? "$(cat /tmp/jqx.o)"
  echo "The tag \"$TAG\" does not exist yet in ${REPOSITORY_HTML_URL}."
  exit 0;;
 200) true;; # ignored
 *) echo "Get tag \"$TAG\" info error!"
  echo "Request error with response code $CODE!"
  exit 31;;
esac

TYPE="$(jq -Mcer type /tmp/tag.json)" || exit 1 # todo
case $TYPE in
 object) REF="$(ex/util/jqx -sfs /tmp/tag.json .ref)" || exit 1 # todo
  if test "$REF" == "refs/tags/$TAG"; then
   echo "The tag \"$TAG\" already exists!"; exit 41
  fi
  exit 42;;
 array) REFS=($(jq -Mcer ".[].ref" /tmp/tag.json)) || exit 1 # todo
  SIZE=${#REFS[*]}
  for ((i = 0; i < SIZE; i++)); do
   REF="${ARRAY[$i]}"
   if test "$REF" == "refs/tags/$TAG"; then
    echo "The tag \"$TAG\" already exists!"; exit 51
   fi
  done; exit 0;;
 *) echo "The type \"$TYPE\" is not supported!"
  exit 61;;
esac

. ex/util/throw 71 "Illegal state error!"
