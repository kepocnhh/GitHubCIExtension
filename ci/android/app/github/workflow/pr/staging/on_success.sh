#!/bin/bash

echo "Workflow pull request staging on success start..."

GIT_COMMIT_SHA=$(ex/util/jqx -sfs assemble/vcs/commit.json .sha) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
AUTHOR_NAME=$(ex/util/jqx -sfs assemble/vcs/commit/author.json .name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
AUTHOR_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/commit/author.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
WORKER_NAME=$(ex/util/jqx -sfs assemble/vcs/worker.json .name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
WORKER_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/worker.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

. ci/workflow/pr/staging/tag.sh

. ex/util/require PR_NUMBER TAG

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

. ex/util/jq/write REPOSITORY_PAGES_HTML_URL -sfs assemble/vcs/repository/pages.json .html_url

. ex/util/jq/write CI_BUILD_NUMBER -si assemble/vcs/actions/run.json .run_number
. ex/util/jq/write CI_BUILD_HTML_URL -sfs assemble/vcs/actions/run.json .html_url

RELEASE_NOTE_URL="${REPOSITORY_PAGES_HTML_URL}build/$CI_BUILD_NUMBER/release/note/index.html"

MESSAGE="Merged by CI build [#$CI_BUILD_NUMBER]($CI_BUILD_HTML_URL)
 - tag [$TAG]($REPOSITORY_HTML_URL/releases/tag/$TAG)
 - release [note]($RELEASE_NOTE_URL)"

ex/github/pr/comment.sh "$MESSAGE" \
 || . ex/util/throw 21 "Illegal state!"

. ex/util/jq/write REPOSITORY_OWNER_LOGIN -sfs assemble/vcs/repository/owner.json .login
. ex/util/jq/write REPOSITORY_OWNER_HTML_URL -sfs assemble/vcs/repository/owner.json .html_url

. ex/util/jq/write REPOSITORY_NAME -sfs assemble/vcs/repository.json .name
. ex/util/jq/write REPOSITORY_HTML_URL -sfs assemble/vcs/repository.json .html_url

MESSAGE="CI build [#$CI_BUILD_NUMBER]($CI_BUILD_HTML_URL)

[$REPOSITORY_OWNER_LOGIN]($REPOSITORY_OWNER_HTML_URL) / [$REPOSITORY_NAME]($REPOSITORY_HTML_URL)

\`*\` [${GIT_COMMIT_SHA::7}]($REPOSITORY_HTML_URL/commit/$GIT_COMMIT_SHA) by [$AUTHOR_NAME]($AUTHOR_HTML_URL)
\`|\\\`
\`| *\` [${GIT_COMMIT_SRC::7}]($REPOSITORY_HTML_URL/commit/$GIT_COMMIT_SRC) by [$AUTHOR_NAME_SRC]($AUTHOR_HTML_URL_SRC)
\`*\` [${GIT_COMMIT_DST::7}]($REPOSITORY_HTML_URL/commit/$GIT_COMMIT_DST) by [$AUTHOR_NAME_DST]($AUTHOR_HTML_URL_DST)

The pull request [#$PR_NUMBER]($REPOSITORY_HTML_URL/pull/$PR_NUMBER) merged by [$WORKER_NAME]($WORKER_HTML_URL)
 - tag [$TAG]($REPOSITORY_HTML_URL/releases/tag/$TAG)
 - release [note]($RELEASE_NOTE_URL)"

ex/notification/telegram/send_message.sh "$MESSAGE" \
 || . ex/util/throw 31 "Illegal state!"
