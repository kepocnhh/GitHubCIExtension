#!/bin/bash

echo "Workflow verify on failed start..."

GIT_COMMIT_SHA=$(ex/util/jqx -sfs assemble/vcs/commit.json .sha) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
GIT_COMMIT_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/commit.json .html_url) \
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
 echo "Diagnostics should have determined the cause of the failure!"; exit 11
fi

. ex/util/jq/write REPOSITORY_PAGES_HTML_URL -sfs assemble/vcs/repository/pages.json .html_url

. ex/util/jq/write CI_BUILD_ID -si assemble/vcs/actions/run.json .id
. ex/util/jq/write CI_BUILD_NUMBER -si assemble/vcs/actions/run.json .run_number
. ex/util/jq/write CI_BUILD_HTML_URL -sfs assemble/vcs/actions/run.json .html_url

REPORT_PATH=$CI_BUILD_NUMBER/$CI_BUILD_ID/diagnostics/report
for ((TYPE_INDEX=0; TYPE_INDEX<SIZE; TYPE_INDEX++)); do
 TYPE="${TYPES[TYPE_INDEX]}"
 . ex/util/jq/write RELATIVE -sfs $ENVIRONMENT ".${TYPE}.path"
 . ex/util/jq/write TITLE -sfs $ENVIRONMENT ".${TYPE}.title"
 VERIFY_RESULT="${VERIFY_RESULT}
    $((TYPE_INDEX+1))) [$TITLE](${REPOSITORY_PAGES_HTML_URL}build/$REPORT_PATH/$RELATIVE/index.html)"
done

. ex/util/jq/write REPOSITORY_NAME -sfs assemble/vcs/repository.json .name
. ex/util/jq/write REPOSITORY_HTML_URL -sfs assemble/vcs/repository.json .html_url

. ex/util/jq/write REPOSITORY_OWNER_LOGIN -sfs assemble/vcs/repository/owner.json .login
. ex/util/jq/write REPOSITORY_OWNER_HTML_URL -sfs assemble/vcs/repository/owner.json .html_url

MESSAGE="CI build [#$CI_BUILD_NUMBER]($CI_BUILD_HTML_URL) failed!

[$REPOSITORY_OWNER_LOGIN]($REPOSITORY_OWNER_HTML_URL) / [$REPOSITORY_NAME]($REPOSITORY_HTML_URL)

 - source [${GIT_COMMIT_SHA::7}]($GIT_COMMIT_HTML_URL) by [$AUTHOR_NAME]($AUTHOR_HTML_URL)
$VERIFY_RESULT"

ex/notification/telegram/send_message.sh "$MESSAGE" \
 || . ex/util/throw 21 "Notification unexpected error!"
