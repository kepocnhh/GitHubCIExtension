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

REPOSITORY_PAGES_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/repository/pages.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

CI_BUILD_NUMBER=$(ex/util/jqx -si assemble/vcs/actions/run.json .run_number) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
CI_BUILD_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/actions/run.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

REPORT_PATH=$CI_BUILD_NUMBER/diagnostics/report
for ((i=0; i<SIZE; i++)); do
 TYPE="${TYPES[i]}"
 RELATIVE=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.path") \
  || . ex/util/throw $? "$(cat /tmp/jqx.o)"
 TITLE=$(ex/util/jqx -sfs $ENVIRONMENT ".${TYPE}.title") \
  || . ex/util/throw $? "$(cat /tmp/jqx.o)"
 VERIFY_RESULT="${VERIFY_RESULT}
    $((i+1))) [$TITLE](${REPOSITORY_PAGES_HTML_URL}build/$REPORT_PATH/$RELATIVE/index.html)"
done

REPOSITORY_NAME=$(ex/util/jqx -sfs assemble/vcs/repository.json .name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
REPOSITORY_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/repository.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

REPOSITORY_OWNER_LOGIN=$(ex/util/jqx -sfs assemble/vcs/repository/owner.json .login) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
REPOSITORY_OWNER_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/repository/owner.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

MESSAGE="CI build [#$CI_BUILD_NUMBER]($CI_BUILD_HTML_URL) failed!

[$REPOSITORY_OWNER_LOGIN]($REPOSITORY_OWNER_HTML_URL) / [$REPOSITORY_NAME]($REPOSITORY_HTML_URL)

 - source [${GIT_COMMIT_SHA::7}]($GIT_COMMIT_HTML_URL) by [$AUTHOR_NAME]($AUTHOR_HTML_URL)
$VERIFY_RESULT"

ex/notification/telegram/send_message.sh "$MESSAGE" \
 || . ex/util/throw 21 "Notification unexpected error!"
