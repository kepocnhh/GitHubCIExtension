#!/bin/bash

echo "Workflow verify on success start..."

CI_BUILD_NUMBER=$(ex/util/jqx -si assemble/vcs/actions/run.json .run_number) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
CI_BUILD_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/actions/run.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

REPOSITORY_OWNER_LOGIN=$(ex/util/jqx -sfs assemble/vcs/repository/owner.json .login) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
REPOSITORY_OWNER_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/repository/owner.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

REPOSITORY_NAME=$(ex/util/jqx -sfs assemble/vcs/repository.json .name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
REPOSITORY_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/repository.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

GIT_COMMIT_SHA=$(ex/util/jqx -sfs assemble/vcs/commit.json .sha) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
GIT_COMMIT_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/commit.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
AUTHOR_NAME=$(ex/util/jqx -sfs assemble/vcs/commit/author.json .name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
AUTHOR_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/commit/author.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

EMOJI_THUMBSUP='%F0%9F%91%8D'

MESSAGE="CI build [#$CI_BUILD_NUMBER]($CI_BUILD_HTML_URL)

[$REPOSITORY_OWNER_LOGIN]($REPOSITORY_OWNER_HTML_URL) / [$REPOSITORY_NAME]($REPOSITORY_HTML_URL)

The commit [${GIT_COMMIT_SHA::7}]($GIT_COMMIT_HTML_URL) by [$AUTHOR_NAME]($AUTHOR_HTML_URL) is verified $EMOJI_THUMBSUP"

ex/notification/telegram/send_message.sh "$MESSAGE" \
 || . ex/util/throw 11 "Notification unexpected error!"
