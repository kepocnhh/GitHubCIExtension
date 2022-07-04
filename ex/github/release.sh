#!/bin/bash

echo "GitHub release..."

REQUIRE_FILLED_STRING="select((.!=null)and(type==\"string\")and(.!=\"\"))" # todo

. ex/util/args/require $# 1

BODY="$1"

CODE=0
RELEASE_NAME="$(echo "$BODY" | jq -Mcer ".name|$REQUIRE_FILLED_STRING")" \
 || . ex/util/throw 12 "Get release name error!"

. ex/util/require VCS_DOMAIN REPOSITORY_OWNER REPOSITORY_NAME

CODE=$(curl -w %{http_code} -o assemble/github/release.json -X POST \
 "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/releases" \
 -H "Authorization: token $VCS_PAT" \
 -d "$BODY")
if test $CODE -ne 201; then
 echo "GitHub release $RELEASE_NAME error!"
 echo "Request error with response code $CODE!"
 exit 31
fi

RELEASE_ID=$(ex/util/jqx -si assemble/github/release.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
RELEASE_HTML_URL=$(ex/util/jqx -sfs assemble/github/release.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

echo "The release $RELEASE_HTML_URL is ready."

exit 0
