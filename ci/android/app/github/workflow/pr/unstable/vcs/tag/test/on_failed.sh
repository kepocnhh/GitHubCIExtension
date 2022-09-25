#!/bin/bash

echo "Workflow pull request unstable VCS tag test on failed..."

ex/github/pr/close.sh \
 || . ex/util/throw 11 "Illegal state!"

. ci/workflow/pr/unstable/tag.sh

. ex/util/require PR_NUMBER TAG

CI_BUILD_NUMBER=$(ex/util/jqx -si assemble/vcs/actions/run.json .run_number) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
CI_BUILD_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/actions/run.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

MESSAGE="Closed by CI build [#$CI_BUILD_NUMBER]($CI_BUILD_HTML_URL)
 - tag \`$TAG\` test  failed!"

ex/github/pr/comment.sh "$MESSAGE" \
 || . ex/util/throw 12 "Illegal state!"

REPOSITORY_OWNER_LOGIN=$(ex/util/jqx -sfs assemble/vcs/repository/owner.json .login) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
REPOSITORY_OWNER_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/repository/owner.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

REPOSITORY_URL=$(ex/util/jqx -sfs assemble/vcs/repository.json .url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
REPOSITORY_NAME=$(ex/util/jqx -sfs assemble/vcs/repository.json .name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
REPOSITORY_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/repository.json .html_url) \
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
WORKER_NAME=$(ex/util/jqx -sfs assemble/vcs/worker.json .name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
WORKER_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/worker.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

MESSAGE="CI build [#$CI_BUILD_NUMBER]($CI_BUILD_HTML_URL) failed!

[$REPOSITORY_OWNER_LOGIN]($REPOSITORY_OWNER_HTML_URL) / [$REPOSITORY_NAME]($REPOSITORY_HTML_URL)

The pull request [#$PR_NUMBER]($REPOSITORY_URL/pull/$PR_NUMBER)
 - source [${GIT_COMMIT_SRC::7}]($REPOSITORY_URL/commit/$GIT_COMMIT_SRC) by [$AUTHOR_NAME_SRC]($AUTHOR_HTML_URL_SRC)
 - destination [${GIT_COMMIT_DST::7}]($REPOSITORY_URL/commit/$GIT_COMMIT_DST) by [$AUTHOR_NAME_DST]($AUTHOR_HTML_URL_DST)
 - tag \`$TAG\` test failed!
 - closed by [$WORKER_NAME]($WORKER_HTML_URL)"

ex/notification/telegram/send_message.sh "$MESSAGE" \
 || . ex/util/throw 21 "Illegal state!"
