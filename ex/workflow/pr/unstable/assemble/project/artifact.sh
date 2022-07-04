#!/bin/bash

echo "Workflow pull request unstable assemble project artifact..."

REQUIRE_FILLED_STRING="select((.!=null)and(type==\"string\")and(.!=\"\"))"

REPOSITORY=repository
[[ -d "$REPOSITORY" ]] || exit 1 # todo

VERSION_NAME="$(jq -Mcer ".version.name|$REQUIRE_FILLED_STRING" assemble/project/common.json)" || exit 1 # todo
for it in REPOSITORY_NAME; do
 if test -z "${!it}"; then echo "$it is empty!"; exit 11; fi; done

ARTIFACT="${REPOSITORY_NAME}-${VERSION_NAME}-UNSTABLE.jar"

CODE=0
gradle -p "$REPOSITORY" lib:assembleUnstableJar; CODE=$?
if test $CODE -ne 0; then
 echo "Assemble \"$ARTIFACT\" error $CODE!"; exit 12
fi

if [[ ! -f $REPOSITORY/lib/build/libs/$ARTIFACT ]]; then
 echo "The file \"$REPOSITORY/lib/build/libs/$ARTIFACT\" does not exists!"; exit 13
fi

rm assemble/project/artifact/$ARTIFACT
mkdir -p assemble/project/artifact
mv $REPOSITORY/lib/build/libs/$ARTIFACT assemble/project/artifact/$ARTIFACT || exit 1 # todo

exit 0
