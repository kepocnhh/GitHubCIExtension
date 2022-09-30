#!/bin/bash

echo "GitHub release upload asset..."

. ex/util/args/require $# 1

ASSETS="$1"

. ex/util/require VCS_PAT ASSETS

SELECT_FILLED_ARRAY="select((type==\"array\")and(.!=[]))"

. ex/util/jq/write RELEASE_UPLOAD_URL -sfs assemble/github/release.json .upload_url
RELEASE_UPLOAD_URL="${RELEASE_UPLOAD_URL//\{?name,label\}/}"

SIZE=$(echo "$ASSETS" | jq -Mcer "$SELECT_FILLED_ARRAY|length") || exit 1 # todo
for ((ASSET_INDEX = 0; ASSET_INDEX<SIZE; ASSET_INDEX++)); do
 ASSET="$(echo "$ASSETS" | jq -Mc ".[$ASSET_INDEX]")"
 ASSET_NAME=$(ex/util/jqj -sfs "$ASSET" .name) \
  || . ex/util/throw $? "$(cat /tmp/jqj.o)"
 echo "Upload asset [$((ASSET_INDEX + 1))/$SIZE] \"$ASSET_NAME\"..."
 ASSET_LABEL=$(ex/util/jqj -sfs "$ASSET" .label) \
  || . ex/util/throw $? "$(cat /tmp/jqj.o)"
 ASSET_PATH=$(ex/util/jqj -sfs "$ASSET" .path) \
  || . ex/util/throw $? "$(cat /tmp/jqj.o)"
 CODE=0
 OUTPUT=/tmp/output
 CODE=$(curl -s -w %{http_code} -o $OUTPUT -X POST \
  "${RELEASE_UPLOAD_URL}?name=${ASSET_NAME}&label=$ASSET_LABEL" \
  -H "Authorization: token $VCS_PAT" \
  -H "Content-Type: text/plain" \
  --data-binary "@$ASSET_PATH")
 if test $CODE -ne 201; then
  echo "GitHub release upload asset \"$ASSET_NAME\" error!"
  echo "Request error with response code $CODE!"
  cat $OUTPUT
  exit 21
 fi
 rm $OUTPUT
done
