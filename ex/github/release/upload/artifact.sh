#!/bin/bash

echo "GitHub release upload artifact..."

. ex/util/args/require $# 1

ARTIFACTS="$1"

. ex/util/require VCS_PAT REPOSITORY_OWNER REPOSITORY_NAME

REQUIRE_INT="select((.!=null)and(type==\"number\"))"
SELECT_FILLED_ARRAY="select((type==\"array\")and(.!=[]))"
REQUIRE_FILLED_STRING="select((.!=null)and(type==\"string\")and(.!=\"\"))"

RELEASE_ID="$(jq -Mcer ".id|$REQUIRE_INT" assemble/github/release.json)" || exit 1 # todo
URL="https://uploads.github.com/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/releases/$RELEASE_ID/assets"

SIZE=$(echo "$ARTIFACTS" | jq -Mcer "$SELECT_FILLED_ARRAY|length") || exit 1 # todo
for ((i = 0; i < SIZE; i++)); do
 ARTIFACT="$(echo "$ARTIFACTS" | jq -Mc ".[$i]")"
 ARTIFACT_NAME="$(echo "$ARTIFACT" | jq -Mcer ".name|$REQUIRE_FILLED_STRING")" || exit $((100+i))
 ARTIFACT_LABEL="$(echo "$ARTIFACT" | jq -Mcer ".label|$REQUIRE_FILLED_STRING")" || exit $((110+i))
 ARTIFACT_PATH="$(echo "$ARTIFACT" | jq -Mcer ".path|$REQUIRE_FILLED_STRING")" || exit $((120+i))
 CODE=$(curl -w %{http_code} -o /tmp/artifact -X POST \
  "$URL?name=$ARTIFACT_NAME&label=$ARTIFACT_LABEL" \
  -H "Authorization: token $VCS_PAT" \
  -H "Content-Type: text/plain" \
  --data-binary "@$ARTIFACT_PATH")
 if test $CODE -ne 201; then
  echo "GitHub release upload artifact $ARTIFACT_NAME error!"
  echo "Request error with response code $CODE!"
  cat /tmp/artifact
  exit 31
 fi
done

exit 0
