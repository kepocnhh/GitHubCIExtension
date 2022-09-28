#!/bin/bash

echo "Workflow pull request snapshot check on failed start..."

ex/github/pr/close.sh \
 || . ex/util/throw 11 "Illegal state!"

VERIFY_RESULT=" - see the report:"
ENVIRONMENT=diagnostics/summary.json
TYPES=($(jq -Mcer "keys|.[]" $ENVIRONMENT))
SIZE=${#TYPES[*]}
if test $SIZE == 0; then
 echo "Diagnostics should have determined the cause of the failure!"; exit 12
fi

. ex/util/jq/write CI_BUILD_NUMBER -si assemble/vcs/actions/run.json .run_number
. ex/util/jq/write CI_BUILD_HTML_URL -sfs assemble/vcs/actions/run.json .html_url

. ex/util/jq/write REPOSITORY_PAGES_HTML_URL -sfs assemble/vcs/repository/pages.json .html_url

REPORT_PATH=$CI_BUILD_NUMBER/diagnostics/report
for ((TYPE_INDEX=0; TYPE_INDEX<SIZE; TYPE_INDEX++)); do
 TYPE="${TYPES[TYPE_INDEX]}"
 . ex/util/jq/write RELATIVE -sfs $ENVIRONMENT ".${TYPE}.path"
 . ex/util/jq/write TITLE -sfs $ENVIRONMENT ".${TYPE}.title"
 VERIFY_RESULT="${VERIFY_RESULT}
    $((TYPE_INDEX+1))) [$TITLE](${REPOSITORY_PAGES_HTML_URL}build/$REPORT_PATH/$RELATIVE/index.html)"
done

MESSAGE="Closed by CI build [#$CI_BUILD_NUMBER]($CI_BUILD_HTML_URL)
$VERIFY_RESULT"

ex/github/pr/comment.sh "$MESSAGE" \
 || . ex/util/throw 21 "Illegal state!"

. ex/util/jq/write REPOSITORY_NAME -sfs assemble/vcs/repository.json .name
. ex/util/jq/write REPOSITORY_HTML_URL -sfs assemble/vcs/repository.json .html_url

. ex/util/jq/write REPOSITORY_OWNER_LOGIN -sfs assemble/vcs/repository/owner.json .login
. ex/util/jq/write REPOSITORY_OWNER_HTML_URL -sfs assemble/vcs/repository/owner.json .html_url

. ex/util/require PR_NUMBER

. ex/util/jq/write GIT_COMMIT_SRC -sfs assemble/vcs/pr${PR_NUMBER}.json .head.sha
. ex/util/jq/write AUTHOR_NAME_SRC -sfs assemble/vcs/commit/author.src.json .name
. ex/util/jq/write AUTHOR_HTML_URL_SRC -sfs assemble/vcs/commit/author.src.json .html_url

. ex/util/jq/write GIT_COMMIT_DST -sfs assemble/vcs/pr${PR_NUMBER}.json .base.sha
. ex/util/jq/write AUTHOR_NAME_DST -sfs assemble/vcs/commit/author.dst.json .name
. ex/util/jq/write AUTHOR_HTML_URL_DST -sfs assemble/vcs/commit/author.dst.json .html_url

. ex/util/jq/write WORKER_NAME -sfs assemble/vcs/worker.json .name
. ex/util/jq/write WORKER_HTML_URL -sfs assemble/vcs/worker.json .html_url

MESSAGE="CI build [#$CI_BUILD_NUMBER]($CI_BUILD_HTML_URL) failed!

[$REPOSITORY_OWNER_LOGIN]($REPOSITORY_OWNER_HTML_URL) / [$REPOSITORY_NAME]($REPOSITORY_HTML_URL)

The pull request [#$PR_NUMBER]($REPOSITORY_HTML_URL/pull/$PR_NUMBER)
 - source [${GIT_COMMIT_SRC::7}]($REPOSITORY_HTML_URL/commit/$GIT_COMMIT_SRC) by [$AUTHOR_NAME_SRC]($AUTHOR_HTML_URL_SRC)
 - destination [${GIT_COMMIT_DST::7}]($REPOSITORY_HTML_URL/commit/$GIT_COMMIT_DST) by [$AUTHOR_NAME_DST]($AUTHOR_HTML_URL_DST)
$VERIFY_RESULT
 - closed by [$WORKER_NAME]($WORKER_HTML_URL)"

ex/notification/telegram/send_message.sh "$MESSAGE" \
 || . ex/util/throw 31 "Notification unexpected error!"
