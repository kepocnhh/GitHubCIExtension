#!/bin/bash

echo "Assemble VCS worker..."

. ex/util/require VCS_DOMAIN VCS_PAT

CODE=0
CODE=$(curl -w %{http_code} -o assemble/vcs/worker.json \
 "$VCS_DOMAIN/user" \
 -H "Authorization: token $VCS_PAT")
if test $CODE -ne 200; then
 echo "Get worker error!"
 echo "Request error with response code $CODE!"
 exit 22
fi

WORKER_ID=$(ex/util/jqx -si assemble/vcs/worker.json .id) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
WORKER_LOGIN=$(ex/util/jqx -sfs assemble/vcs/worker.json .login) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

WORKER_VCS_EMAIL="${WORKER_ID}+${WORKER_LOGIN}@users.noreply.github.com"

echo "$(jq ".vcs_email=\"$WORKER_VCS_EMAIL\"" assemble/vcs/worker.json)" > assemble/vcs/worker.json

WORKER_HTML_URL=$(ex/util/jqx -sfs assemble/vcs/worker.json .html_url) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

echo "The worker $WORKER_HTML_URL is ready."

exit 0
