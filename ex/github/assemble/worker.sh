#!/bin/bash

echo "Assemble VCS worker..."

. ex/util/require VCS_DOMAIN VCS_PAT

CODE=0
CODE=$(curl -s -w %{http_code} -o assemble/vcs/worker.json \
 "$VCS_DOMAIN/user" \
 -H "Authorization: token $VCS_PAT")
if test $CODE -ne 200; then
 echo "Get worker error!"
 echo "Request error with response code $CODE!"
 exit 11
fi

. ex/util/json -f assemble/vcs/worker.json \
 -si .id WORKER_ID \
 -sfs .login WORKER_LOGIN \
 -sfs .html_url WORKER_HTML_URL

WORKER_VCS_EMAIL="${WORKER_ID}+${WORKER_LOGIN}@users.noreply.github.com"

echo "$(jq ".vcs_email=\"$WORKER_VCS_EMAIL\"" assemble/vcs/worker.json)" > assemble/vcs/worker.json

echo "The worker $WORKER_HTML_URL is ready."
