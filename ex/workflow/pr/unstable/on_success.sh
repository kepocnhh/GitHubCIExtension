#!/bin/bash

echo "Workflow pull request unstable on success start..."

. ex/util/require REPOSITORY_OWNER REPOSITORY_NAME GITHUB_RUN_NUMBER GITHUB_RUN_ID PR_NUMBER

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

VERSION_NAME=$(ex/util/jqx -sfs assemble/project/common.json .version.name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
TAG="${VERSION_NAME}-UNSTABLE"

REPOSITORY_URL=https://github.com/$REPOSITORY_OWNER/$REPOSITORY_NAME

MESSAGE="Merged by CI build [#$GITHUB_RUN_NUMBER]($REPOSITORY_URL/actions/runs/$GITHUB_RUN_ID)
 - release [$TAG]($REPOSITORY_URL/releases/tag/$TAG)"

/bin/bash ex/vcs/pr/comment.sh "$MESSAGE" || exit 31 # todo

MESSAGE="CI build [#$GITHUB_RUN_NUMBER]($REPOSITORY_URL/actions/runs/$GITHUB_RUN_ID)

[$REPOSITORY_OWNER](https://github.com/$REPOSITORY_OWNER) / [$REPOSITORY_NAME]($REPOSITORY_URL)

\`*\` [${GIT_COMMIT_SHA::7}]($REPOSITORY_URL/commit/$GIT_COMMIT_SHA) by [$AUTHOR_NAME]($AUTHOR_HTML_URL)
\`|\\\`
\`| *\` [${GIT_COMMIT_SRC::7}]($REPOSITORY_URL/commit/$GIT_COMMIT_SRC) by [$AUTHOR_NAME_SRC]($AUTHOR_HTML_URL_SRC)
\`*\` [${GIT_COMMIT_DST::7}]($REPOSITORY_URL/commit/$GIT_COMMIT_DST) by [$AUTHOR_NAME_DST]($AUTHOR_HTML_URL_DST)

The pull request [#$PR_NUMBER]($REPOSITORY_URL/pull/$PR_NUMBER) merged by [$WORKER_NAME]($WORKER_HTML_URL)
 - release [$TAG]($REPOSITORY_URL/releases/tag/$TAG)"

/bin/bash ex/notification/telegram/send_message.sh "$MESSAGE" || exit 32

exit 0
