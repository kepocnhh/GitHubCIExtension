#!/bin/bash

echo "VCS tag test..."

REQUIRE_FILLED_STRING="select((.!=null)and(type==\"string\")and(.!=\"\"))"

. ex/util/args/require $# 1

TAG="$1"

. ex/util/require VCS_DOMAIN REPOSITORY_OWNER REPOSITORY_NAME TAG

CODE=0
CODE=$(curl -w %{http_code} -o /tmp/tag.json \
 "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/git/refs/tags/$TAG")
case $CODE in
 404) echo "The tag \"$TAG\" does not exist yet in https://github.com/$REPOSITORY_OWNER/$REPOSITORY_NAME."
  exit 0;;
 200) true;; # ignored
 *) echo "Get tag \"$TAG\" info error!"
  echo "Request error with response code $CODE!"
  exit 31;;
esac

TYPE="$(jq -Mcer type /tmp/tag.json)" || exit 1 # todo
case $TYPE in
 object) REF="$(jq -Mcer ".ref|$REQUIRE_FILLED_STRING" /tmp/tag.json)" || exit 1 # todo
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
