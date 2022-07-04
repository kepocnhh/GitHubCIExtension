#!/bin/bash

echo "Workflow verify on failed start..."

. ex/util/require REPOSITORY_OWNER REPOSITORY_NAME GITHUB_RUN_NUMBER GITHUB_RUN_ID

GIT_COMMIT_SHA=$(ex/util/jqx -sfs assemble/vcs/commit.json .sha) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
AUTHOR_NAME=$(ex/util/jqx -sfs assemble/vcs/commit/author.json .name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
AUTHOR_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/commit/author.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

VERIFY_RESULT=" - see the report:"
ENVIRONMENT=diagnostics/summary.json
TYPES=($(jq -Mcer "keys|.[]" $ENVIRONMENT))
SIZE=${#TYPES[*]}
if test $SIZE == 0; then
 echo "Diagnostics should have determined the cause of the failure!"; exit 1
fi

PAGES_URL="https://${REPOSITORY_OWNER}.github.io/$REPOSITORY_NAME"
REPORT_PATH=$GITHUB_RUN_NUMBER/$GITHUB_RUN_ID/diagnostics/report
for ((i=0; i<SIZE; i++)); do
 TYPE="${TYPES[i]}"
 RELATIVE=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.path") \
  || . ex/util/throw $? "$(cat /tmp/jqx.o)"
 TITLE=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.title") \
  || . ex/util/throw $? "$(cat /tmp/jqx.o)"
 VERIFY_RESULT="${VERIFY_RESULT}
    $((i+1))) [$TITLE](${PAGES_URL}/build/$REPORT_PATH/$RELATIVE/index.html)"
done

REPOSITORY_URL=https://github.com/$REPOSITORY_OWNER/$REPOSITORY_NAME

MESSAGE="CI build [#$GITHUB_RUN_NUMBER]($REPOSITORY_URL/actions/runs/$GITHUB_RUN_ID) failed!

[$REPOSITORY_OWNER](https://github.com/$REPOSITORY_OWNER) / [$REPOSITORY_NAME]($REPOSITORY_URL)

 - source [${GIT_COMMIT_SHA::7}]($REPOSITORY_URL/commit/$GIT_COMMIT_SHA) by [$AUTHOR_NAME]($AUTHOR_HTML_URL)
$VERIFY_RESULT"

/bin/bash repository/buildSrc/src/main/resources/bash/notification/telegram/send_message.sh "$MESSAGE" || exit 31

exit 0
