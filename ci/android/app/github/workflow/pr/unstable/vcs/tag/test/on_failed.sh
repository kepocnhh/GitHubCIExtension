#!/bin/bash

echo "Workflow pull request unstable VCS tag test on failed..."

ex/github/pr/close.sh \
 || . ex/util/throw 11 "Illegal state!"

. ci/workflow/pr/unstable/tag.sh

. ex/util/require PR_NUMBER TAG

. ex/util/json -f assemble/vcs/actions/run.json \
 -si .run_number CI_BUILD_NUMBER \
 -sfs .html_url CI_BUILD_HTML_URL

MESSAGE="Closed by CI build [#$CI_BUILD_NUMBER]($CI_BUILD_HTML_URL)
 - tag \`$TAG\` test  failed!"

ex/github/pr/comment.sh "$MESSAGE" \
 || . ex/util/throw 12 "Illegal state!"

. ex/util/json -f assemble/vcs/repository/owner.json \
 -sfs .login REPOSITORY_OWNER_LOGIN \
 -sfs .html_url REPOSITORY_OWNER_HTML_URL

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .name REPOSITORY_NAME \
 -sfs .html_url REPOSITORY_HTML_URL

. ex/util/require PR_NUMBER

. ex/util/json -f assemble/vcs/pr${PR_NUMBER}.json \
 -sfs .head.sha GIT_COMMIT_SRC \
 -sfs .base.sha GIT_COMMIT_DST

. ex/util/json -f assemble/vcs/commit/author.src.json \
 -sfs .name AUTHOR_NAME_SRC \
 -sfs .html_url AUTHOR_HTML_URL_SRC

. ex/util/json -f assemble/vcs/commit/author.dst.json \
 -sfs .name AUTHOR_NAME_DST \
 -sfs .html_url AUTHOR_HTML_URL_DST

. ex/util/json -f assemble/vcs/worker.json \
 -sfs .name WORKER_NAME \
 -sfs .html_url WORKER_HTML_URL

MESSAGE="CI build [#$CI_BUILD_NUMBER]($CI_BUILD_HTML_URL) failed!

[$REPOSITORY_OWNER_LOGIN]($REPOSITORY_OWNER_HTML_URL) / [$REPOSITORY_NAME]($REPOSITORY_HTML_URL)

The pull request [#$PR_NUMBER]($REPOSITORY_HTML_URL/pull/$PR_NUMBER)
 - source [${GIT_COMMIT_SRC::7}]($REPOSITORY_HTML_URL/commit/$GIT_COMMIT_SRC) by [$AUTHOR_NAME_SRC]($AUTHOR_HTML_URL_SRC)
 - destination [${GIT_COMMIT_DST::7}]($REPOSITORY_HTML_URL/commit/$GIT_COMMIT_DST) by [$AUTHOR_NAME_DST]($AUTHOR_HTML_URL_DST)
 - tag \`$TAG\` test failed!
 - closed by [$WORKER_NAME]($WORKER_HTML_URL)"

ex/notification/telegram/send_message.sh "$MESSAGE" \
 || . ex/util/throw 21 "Illegal state!"
