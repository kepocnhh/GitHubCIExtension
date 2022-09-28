#!/bin/bash

echo "Workflow pull request staging task fix..."

. ex/util/args/require $# 2

ISSUE_NUMBER="$1"
MESSAGE="$2"

. ex/util/require ISSUE_NUMBER MESSAGE LABEL_ID_STAGING LABEL_ID_SNAPSHOT

ex/github/issue.sh "$ISSUE_NUMBER" || . ex/util/throw 11 "Illegal state!"

LABEL_ID=$LABEL_ID_STAGING
IS_READY_FOR_TEST="$(jq ".labels|any(.id==$LABEL_ID)" assemble/github/issue${ISSUE_NUMBER}.json)"
LABEL_NAME="$(echo "$(jq ".[]|select(.id==$LABEL_ID)" assemble/github/labels.json)" | jq -r .name)"
if test "$IS_READY_FOR_TEST" == "true"; then
 . ex/util/success "The issue #$ISSUE_NUMBER is already marked as \"$LABEL_NAME\"."
elif test "$IS_READY_FOR_TEST" != "false"; then
 . ex/util/throw 21 "The issue #$ISSUE_NUMBER label \"$LABEL_NAME\" error!"
fi

LABEL_ID=$LABEL_ID_SNAPSHOT
IS_TESTED="$(jq ".labels|any(.id==$LABEL_ID)" assemble/github/issue${ISSUE_NUMBER}.json)"
LABEL_NAME="$(echo "$(jq ".[]|select(.id==$LABEL_ID)" assemble/github/labels.json)" | jq -r .name)"
if test "$IS_TESTED" == "true"; then
 . ex/util/success "The issue #$ISSUE_NUMBER is already marked as \"$LABEL_NAME\"."
elif test "$IS_TESTED" != "false"; then
 . ex/util/throw 22 "The issue #$ISSUE_NUMBER label \"$LABEL_NAME\" error!"
fi

ISSUE_STATE=$(ex/util/jqx -sfs assemble/github/issue${ISSUE_NUMBER}.json .state) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
if test "$ISSUE_STATE" == "closed"; then
 . ex/util/success "The issue #$ISSUE_NUMBER is closed."
elif test "$ISSUE_STATE" != "open"; then
 . ex/util/throw 23 "The issue #$ISSUE_NUMBER state error!"
fi

ex/github/issue/comment.sh "$ISSUE_NUMBER" "$MESSAGE" \
 || . ex/util/throw 12 "Illegal state!"
echo "$(jq ".+[$(cat assemble/github/issue${ISSUE_NUMBER}.json)]" assemble/github/fixed.json)" \
 > assemble/github/fixed.json \
 || . ex/util/throw 13 "Illegal state!"
ci/workflow/pr/task/patch.sh "$ISSUE_NUMBER" "$LABEL_ID_STAGING" \
 || . ex/util/throw 14 "Illegal state!"
