#!/bin/bash

echo "Workflow pull request snapshot task fix..."

. ex/util/args/require $# 2

ISSUE_NUMBER="$1"
MESSAGE="$2"

. ex/util/require ISSUE_NUMBER MESSAGE LABEL_ID_STAGING LABEL_ID_SNAPSHOT

/bin/bash ex/github/issue.sh "$ISSUE_NUMBER" \
 || . ex/util/throw 11 "Issue unexpected error!"

LABEL_ID=$LABEL_ID_SNAPSHOT
IS_TESTED="$(jq ".labels|any(.id==$LABEL_ID)" assemble/github/issue${ISSUE_NUMBER}.json)"
LABEL_NAME="$(echo "$(jq ".[]|select(.id==$LABEL_ID)" assemble/github/labels.json)" | jq -r .name)"
if test "$IS_TESTED" == "true"; then
 echo "The issue #$ISSUE_NUMBER is already marked as \"$LABEL_NAME\"."
 exit 0
elif test "$IS_TESTED" != "false"; then
 echo "The issue #$ISSUE_NUMBER label \"$LABEL_NAME\" error!"; exit 2
fi

LABEL_ID=$LABEL_ID_STAGING
IS_READY_FOR_TEST="$(jq ".labels|any(.id==$LABEL_ID)" assemble/github/issue${ISSUE_NUMBER}.json)"
LABEL_NAME="$(echo "$(jq ".[]|select(.id==$LABEL_ID)" assemble/github/labels.json)" | jq -r .name)"
if test "$IS_READY_FOR_TEST" == "false"; then
 echo "The issue #$ISSUE_NUMBER is already marked as \"$LABEL_NAME\"."
 exit 0
elif test "$IS_READY_FOR_TEST" != "true"; then
 echo "The issue #$ISSUE_NUMBER label \"$LABEL_NAME\" error!"; exit 2
fi

ISSUE_STATE=$(ex/util/jqx -sfs assemble/github/issue${ISSUE_NUMBER}.json .state) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
if test "$ISSUE_STATE" == "closed"; then
 echo "The issue #$ISSUE_NUMBER is closed."; exit 0
elif test "$ISSUE_STATE" != "open"; then
 echo "The issue #$ISSUE_NUMBER state error!"; exit 2
fi

/bin/bash ex/github/issue/comment.sh "$ISSUE_NUMBER" "$MESSAGE" \
 || . ex/util/throw 12 "Issue comment unexpected error!"

echo "$(jq ".+[$(cat assemble/github/issue${ISSUE_NUMBER}.json)]" assemble/github/fixed.json)" \
 > assemble/github/fixed.json \
 || . ex/util/throw 13 "Issue fixed unexpected error!"
/bin/bash ex/workflow/pr/task/patch.sh "$ISSUE_NUMBER" "$LABEL_ID_SNAPSHOT" \
 || . ex/util/throw 14 "Issue patch unexpected error!"

exit 0
