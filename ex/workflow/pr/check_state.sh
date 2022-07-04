#!/bin/bash

echo "Workflow pull request check state..."

. ex/util/args/require $# 1

EXPECTED_STATE="$1"

. ex/util/require PR_NUMBER EXPECTED_STATE

for (( i=0; i<10; i++ )); do
 /bin/bash ex/vcs/pr/check_state.sh "$EXPECTED_STATE" && exit 0
 echo "check failed for the $i time..."
 sleep 1
done

echo "The pull request #$PR_NUMBER state is not \"$EXPECTED_STATE\"!"

exit 12
