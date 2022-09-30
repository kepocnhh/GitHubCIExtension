#!/bin/bash

echo "Workflow pull request snapshot on success start..."

. ci/workflow/pr/snapshot/tag.sh

. ex/util/require PR_NUMBER TAG

. ex/util/json -f assemble/vcs/actions/run.json \
 -si .id CI_BUILD_ID \
 -si .run_number CI_BUILD_NUMBER \
 -sfs .html_url CI_BUILD_HTML_URL

. ex/util/json -f assemble/vcs/repository/pages.json \
 -sfs .html_url REPOSITORY_PAGES_HTML_URL

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .name REPOSITORY_NAME \
 -sfs .html_url REPOSITORY_HTML_URL

RELEASE_NOTE_URL="${REPOSITORY_PAGES_HTML_URL}build/$CI_BUILD_NUMBER/$CI_BUILD_ID/release/note/index.html"

REPORT=" - tag [$TAG]($REPOSITORY_HTML_URL/releases/tag/$TAG)
 - release [note]($RELEASE_NOTE_URL)"

MESSAGE="Merged by CI build [#$CI_BUILD_NUMBER]($CI_BUILD_HTML_URL)
$REPORT"

ex/github/pr/comment.sh "$MESSAGE" \
 || . ex/util/throw 21 "Illegal state!"

. ex/util/json -f assemble/vcs/repository/owner.json \
 -sfs .login REPOSITORY_OWNER_LOGIN \
 -sfs .html_url REPOSITORY_OWNER_HTML_URL

. ex/util/json -f assemble/vcs/pr${PR_NUMBER}.json \
 -sfs .head.sha GIT_COMMIT_SRC \
 -sfs .base.sha GIT_COMMIT_DST

. ex/util/json -f assemble/vcs/commit.json \
 -sfs .sha GIT_COMMIT_SHA

. ex/util/json -f assemble/vcs/commit/author.src.json \
 -sfs .name AUTHOR_NAME_SRC \
 -sfs .html_url AUTHOR_HTML_URL_SRC

. ex/util/json -f assemble/vcs/commit/author.dst.json \
 -sfs .name AUTHOR_NAME_DST \
 -sfs .html_url AUTHOR_HTML_URL_DST

. ex/util/json -f assemble/vcs/commit/author.json \
 -sfs .name AUTHOR_NAME \
 -sfs .html_url AUTHOR_HTML_URL

. ex/util/json -f assemble/vcs/worker.json \
 -sfs .name WORKER_NAME \
 -sfs .html_url WORKER_HTML_URL

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
