#!/bin/bash

echo "Workflow verify on failed start..."

VERIFY_RESULT=" - see the report:"
ENVIRONMENT=diagnostics/summary.json
TYPES=($(jq -Mcer "keys|.[]" $ENVIRONMENT))
SIZE=${#TYPES[*]}
if test $SIZE == 0; then
 echo "Diagnostics should have determined the cause of the failure!"; exit 11
fi

. ex/util/json -f assemble/vcs/repository/pages.json \
 -sfs .html_url REPOSITORY_PAGES_HTML_URL

. ex/util/json -f assemble/vcs/actions/run.json \
 -si .id CI_BUILD_ID \
 -si .run_number CI_BUILD_NUMBER \
 -sfs .html_url CI_BUILD_HTML_URL

REPORT_PATH=$CI_BUILD_NUMBER/$CI_BUILD_ID/diagnostics/report
for ((TYPE_INDEX=0; TYPE_INDEX<SIZE; TYPE_INDEX++)); do
 TYPE="${TYPES[TYPE_INDEX]}"
 . ex/util/json -f $ENVIRONMENT \
  -sfs ".${TYPE}.path" RELATIVE \
  -sfs ".${TYPE}.title" TITLE
 VERIFY_RESULT="${VERIFY_RESULT}
    $((TYPE_INDEX+1))) [$TITLE](${REPOSITORY_PAGES_HTML_URL}build/$REPORT_PATH/$RELATIVE/index.html)"
done

. ex/util/json -f assemble/vcs/repository/owner.json \
 -sfs .login REPOSITORY_OWNER_LOGIN \
 -sfs .html_url REPOSITORY_OWNER_HTML_URL

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .name REPOSITORY_NAME \
 -sfs .html_url REPOSITORY_HTML_URL

. ex/util/json -f assemble/vcs/commit.json \
 -sfs .sha GIT_COMMIT_SHA

. ex/util/json -f assemble/vcs/commit/author.json \
 -sfs .name AUTHOR_NAME \
 -sfs .html_url AUTHOR_HTML_URL

MESSAGE="CI build [#$CI_BUILD_NUMBER]($CI_BUILD_HTML_URL) failed!

[$REPOSITORY_OWNER_LOGIN]($REPOSITORY_OWNER_HTML_URL) / [$REPOSITORY_NAME]($REPOSITORY_HTML_URL)

 - source [${GIT_COMMIT_SHA::7}]($REPOSITORY_HTML_URL/commit/$GIT_COMMIT_SHA) by [$AUTHOR_NAME]($AUTHOR_HTML_URL)
$VERIFY_RESULT"

ex/notification/telegram/send_message.sh "$MESSAGE" \
 || . ex/util/throw 21 "Notification unexpected error!"
