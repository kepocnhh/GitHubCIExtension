#!/bin/bash

echo "GitHub release upload asset..."

. ex/util/args/require $# 1

ASSETS="$1"

. ex/util/require VCS_PAT ASSETS

SELECT_FILLED_ARRAY="select((type==\"array\")and(.!=[]))"

RELEASE_UPLOAD_URL=$(ex/util/jqx -sfs assemble/github/release.json .upload_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
RELEASE_UPLOAD_URL="${RELEASE_UPLOAD_URL//\{?name,label\}/}"

SIZE=$(echo "$ASSETS" | jq -Mcer "$SELECT_FILLED_ARRAY|length") || exit 1 # todo
for ((i = 0; i < SIZE; i++)); do
 ASSET="$(echo "$ASSETS" | jq -Mc ".[$i]")"
 ASSET_NAME=$(ex/util/jqj -sfs "$ASSET" .name) \
  || . ex/util/throw $? "$(cat /tmp/jqj.o)"
 echo "Upload asset [$i/$SIZE] ${ASSET_NAME}..."
 ASSET_LABEL=$(ex/util/jqj -sfs "$ASSET" .label) \
  || . ex/util/throw $? "$(cat /tmp/jqj.o)"
 ASSET_PATH=$(ex/util/jqj -sfs "$ASSET" .path) \
  || . ex/util/throw $? "$(cat /tmp/jqj.o)"
 CODE=$(curl -s -w %{http_code} -o /tmp/asset -X POST \
  "${RELEASE_UPLOAD_URL}?name=${ASSET_NAME}&label=$ASSET_LABEL" \
  -H "Authorization: token $VCS_PAT" \
  -H "Content-Type: text/plain" \
  --data-binary "@$ASSET_PATH")
 if test $CODE -ne 201; then
  echo "GitHub release upload asset $ASSET_NAME error!"
  echo "Request error with response code $CODE!"
  cat /tmp/asset
  exit 31
 fi
 rm /tmp/asset
done
