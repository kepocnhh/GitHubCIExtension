#!/bin/bash

echo "Workflow verify on success start..."

. ex/util/json -f assemble/vcs/actions/run.json \
 -si .run_number CI_BUILD_NUMBER \
 -sfs .html_url CI_BUILD_HTML_URL

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

EMOJI_THUMBSUP='%F0%9F%91%8D'

MESSAGE="CI build [#$CI_BUILD_NUMBER]($CI_BUILD_HTML_URL)

[$REPOSITORY_OWNER_LOGIN]($REPOSITORY_OWNER_HTML_URL) / [$REPOSITORY_NAME]($REPOSITORY_HTML_URL)

The commit [${GIT_COMMIT_SHA::7}]($REPOSITORY_HTML_URL/commit/$GIT_COMMIT_SHA) by [$AUTHOR_NAME]($AUTHOR_HTML_URL) is verified $EMOJI_THUMBSUP"

ex/notification/telegram/send_message.sh "$MESSAGE" \
 || . ex/util/throw 11 "Notification unexpected error!"
