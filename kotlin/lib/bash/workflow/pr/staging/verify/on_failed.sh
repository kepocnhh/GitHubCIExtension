#!/bin/bash

echo "Workflow pull request staging verify on failed start..."

ex/vcs/pr/close.sh || exit 11 # todo

. ex/util/require REPOSITORY_OWNER REPOSITORY_NAME \
 GITHUB_RUN_NUMBER GITHUB_RUN_ID PR_NUMBER

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

MESSAGE="Closed by CI build [#$GITHUB_RUN_NUMBER]($REPOSITORY_URL/actions/runs/$GITHUB_RUN_ID)
$VERIFY_RESULT"

ex/vcs/pr/comment.sh "$MESSAGE" || exit 31 # todo

GIT_COMMIT_SRC=$(ex/util/jqx -sfs assemble/vcs/pr${PR_NUMBER}.json .head.sha) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
AUTHOR_NAME_SRC=$(ex/util/jqx -sfs assemble/vcs/commit/author.src.json .name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
AUTHOR_HTML_URL_SRC=$(ex/util/jqx -sfs assemble/vcs/commit/author.src.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
GIT_COMMIT_DST=$(ex/util/jqx -sfs assemble/vcs/pr${PR_NUMBER}.json .base.sha) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
AUTHOR_NAME_DST=$(ex/util/jqx -sfs assemble/vcs/commit/author.dst.json .name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
AUTHOR_HTML_URL_DST=$(ex/util/jqx -sfs assemble/vcs/commit/author.dst.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
WORKER_NAME=$(ex/util/jqx -sfs assemble/vcs/worker.json .name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
WORKER_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/worker.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

MESSAGE="CI build [#$GITHUB_RUN_NUMBER]($REPOSITORY_URL/actions/runs/$GITHUB_RUN_ID) failed!

[$REPOSITORY_OWNER](https://github.com/$REPOSITORY_OWNER) / [$REPOSITORY_NAME]($REPOSITORY_URL)

The pull request [#$PR_NUMBER]($REPOSITORY_URL/pull/$PR_NUMBER)
 - source [${GIT_COMMIT_SRC::7}]($REPOSITORY_URL/commit/$GIT_COMMIT_SRC) by [$AUTHOR_NAME_SRC]($AUTHOR_HTML_URL_SRC)
 - destination [${GIT_COMMIT_DST::7}]($REPOSITORY_URL/commit/$GIT_COMMIT_DST) by [$AUTHOR_NAME_DST]($AUTHOR_HTML_URL_DST)
$VERIFY_RESULT
 - closed by [$WORKER_NAME]($WORKER_HTML_URL)"

ex/notification/telegram/send_message.sh "$MESSAGE" \
 || . ex/util/throw 31 "Notification unexpected error!"

exit 0
