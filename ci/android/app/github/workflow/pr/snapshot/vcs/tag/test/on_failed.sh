#!/bin/bash

echo "Workflow pull request snapshot VCS tag test on failed..."

ex/github/pr/close.sh \
 || . ex/util/throw 11 "Illegal state!"

. ci/workflow/pr/snapshot/tag.sh

. ex/util/require PR_NUMBER TAG

. ex/util/jq/write CI_BUILD_NUMBER -si assemble/vcs/actions/run.json .run_number
. ex/util/jq/write CI_BUILD_HTML_URL -sfs assemble/vcs/actions/run.json .html_url

MESSAGE="Closed by CI build [#$CI_BUILD_NUMBER]($CI_BUILD_HTML_URL)
 - tag \`$TAG\` test  failed!"

ex/github/pr/comment.sh "$MESSAGE" \
 || . ex/util/throw 12 "Illegal state!"

. ex/util/jq/write REPOSITORY_OWNER_LOGIN -sfs assemble/vcs/repository/owner.json .login
. ex/util/jq/write REPOSITORY_OWNER_HTML_URL -sfs assemble/vcs/repository/owner.json .html_url

. ex/util/jq/write REPOSITORY_NAME -sfs assemble/vcs/repository.json .name
. ex/util/jq/write REPOSITORY_HTML_URL -sfs assemble/vcs/repository.json .html_url

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
 - tag \`$TAG\` test failed!
 - closed by [$WORKER_NAME]($WORKER_HTML_URL)"

ex/notification/telegram/send_message.sh "$MESSAGE" \
 || . ex/util/throw 21 "Illegal state!"
