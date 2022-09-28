#!/bin/bash

echo "Workflow verify on success start..."

. ex/util/jq/write CI_BUILD_NUMBER -si assemble/vcs/actions/run.json .run_number
. ex/util/jq/write CI_BUILD_HTML_URL -sfs assemble/vcs/actions/run.json .html_url

. ex/util/jq/write REPOSITORY_OWNER_LOGIN -sfs assemble/vcs/repository/owner.json .login
. ex/util/jq/write REPOSITORY_OWNER_HTML_URL -sfs assemble/vcs/repository/owner.json .html_url

. ex/util/jq/write REPOSITORY_NAME -sfs assemble/vcs/repository.json .name
. ex/util/jq/write REPOSITORY_HTML_URL -sfs assemble/vcs/repository.json .html_url

. ex/util/jq/write GIT_COMMIT_SHA -sfs assemble/vcs/commit.json .sha
. ex/util/jq/write AUTHOR_NAME -sfs assemble/vcs/commit/author.json .name
. ex/util/jq/write AUTHOR_HTML_URL -sfs assemble/vcs/commit/author.json .html_url

EMOJI_THUMBSUP='%F0%9F%91%8D'

MESSAGE="CI build [#$CI_BUILD_NUMBER]($CI_BUILD_HTML_URL)

[$REPOSITORY_OWNER_LOGIN]($REPOSITORY_OWNER_HTML_URL) / [$REPOSITORY_NAME]($REPOSITORY_HTML_URL)

The commit [${GIT_COMMIT_SHA::7}]($REPOSITORY_HTML_URL/commit/$GIT_COMMIT_SHA) by [$AUTHOR_NAME]($AUTHOR_HTML_URL) is verified $EMOJI_THUMBSUP"

ex/notification/telegram/send_message.sh "$MESSAGE" \
 || . ex/util/throw 11 "Notification unexpected error!"
