#!/bin/bash

echo "Workflow pull request snapshot on success start..."

. ci/workflow/pr/snapshot/tag.sh

. ex/util/require PR_NUMBER TAG

. ex/util/jq/write REPOSITORY_PAGES_HTML_URL -sfs assemble/vcs/repository/pages.json .html_url

. ex/util/jq/write CI_BUILD_NUMBER -si assemble/vcs/actions/run.json .run_number
. ex/util/jq/write CI_BUILD_HTML_URL -sfs assemble/vcs/actions/run.json .html_url

RELEASE_NOTE_URL="${REPOSITORY_PAGES_HTML_URL}build/$CI_BUILD_NUMBER/release/note/index.html"

REPORT=" - tag [$TAG]($REPOSITORY_HTML_URL/releases/tag/$TAG)
 - release [note]($RELEASE_NOTE_URL)"

MESSAGE="Merged by CI build [#$CI_BUILD_NUMBER]($CI_BUILD_HTML_URL)
$REPORT"

ex/github/pr/comment.sh "$MESSAGE" \
 || . ex/util/throw 21 "Illegal state!"

. ex/util/jq/write REPOSITORY_OWNER_LOGIN -sfs assemble/vcs/repository/owner.json .login
. ex/util/jq/write REPOSITORY_OWNER_HTML_URL -sfs assemble/vcs/repository/owner.json .html_url

. ex/util/jq/write REPOSITORY_NAME -sfs assemble/vcs/repository.json .name
. ex/util/jq/write REPOSITORY_HTML_URL -sfs assemble/vcs/repository.json .html_url

. ex/util/jq/write GIT_COMMIT_SHA -sfs assemble/vcs/commit.json .sha
. ex/util/jq/write AUTHOR_NAME -sfs assemble/vcs/commit/author.json .name
. ex/util/jq/write AUTHOR_HTML_URL -sfs assemble/vcs/commit/author.json .html_url

. ex/util/jq/write GIT_COMMIT_SRC -sfs assemble/vcs/pr${PR_NUMBER}.json .head.sha
. ex/util/jq/write AUTHOR_NAME_SRC -sfs assemble/vcs/commit/author.src.json .name
. ex/util/jq/write AUTHOR_HTML_URL_SRC -sfs assemble/vcs/commit/author.src.json .html_url

. ex/util/jq/write GIT_COMMIT_DST -sfs assemble/vcs/pr${PR_NUMBER}.json .base.sha
. ex/util/jq/write AUTHOR_NAME_DST -sfs assemble/vcs/commit/author.dst.json .name
. ex/util/jq/write AUTHOR_HTML_URL_DST -sfs assemble/vcs/commit/author.dst.json .html_url

. ex/util/jq/write WORKER_NAME -sfs assemble/vcs/worker.json .name
. ex/util/jq/write WORKER_HTML_URL -sfs assemble/vcs/worker.json .html_url

MESSAGE="CI build [#$CI_BUILD_NUMBER]($CI_BUILD_HTML_URL)

[$REPOSITORY_OWNER_LOGIN]($REPOSITORY_OWNER_HTML_URL) / [$REPOSITORY_NAME]($REPOSITORY_HTML_URL)

\`*\` [${GIT_COMMIT_SHA::7}]($REPOSITORY_HTML_URL/commit/$GIT_COMMIT_SHA) by [$AUTHOR_NAME]($AUTHOR_HTML_URL)
\`|\\\`
\`| *\` [${GIT_COMMIT_SRC::7}]($REPOSITORY_HTML_URL/commit/$GIT_COMMIT_SRC) by [$AUTHOR_NAME_SRC]($AUTHOR_HTML_URL_SRC)
\`*\` [${GIT_COMMIT_DST::7}]($REPOSITORY_HTML_URL/commit/$GIT_COMMIT_DST) by [$AUTHOR_NAME_DST]($AUTHOR_HTML_URL_DST)

The pull request [#$PR_NUMBER]($REPOSITORY_HTML_URL/pull/$PR_NUMBER) merged by [$WORKER_NAME]($WORKER_HTML_URL)
$REPORT"

ex/notification/telegram/send_message.sh "$MESSAGE" \
 || . ex/util/throw 31 "Illegal state!"
