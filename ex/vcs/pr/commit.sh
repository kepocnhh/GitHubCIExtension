#!/bin/bash

echo "VCS pull request commit..."

REQUIRE_FILLED_STRING="select((.!=null)and(type==\"string\")and(.!=\"\"))"

WORKER_NAME="$(jq -Mcer ".name|$REQUIRE_FILLED_STRING" assemble/vcs/worker.json)"
WORKER_VCS_EMAIL="$(jq -Mcer ".vcs_email|$REQUIRE_FILLED_STRING" assemble/vcs/worker.json)"

for it in WORKER_NAME WORKER_VCS_EMAIL PR_NUMBER; do
 if test -z "${!it}"; then echo "$it is empty!"; exit 11; fi; done

GIT_COMMIT_SRC="$(jq -Mcer ".head.sha|$REQUIRE_FILLED_STRING" assemble/vcs/pr${PR_NUMBER}.json)"
GIT_COMMIT_DST="$(jq -Mcer ".base.sha|$REQUIRE_FILLED_STRING" assemble/vcs/pr${PR_NUMBER}.json)"

for it in GIT_COMMIT_SRC GIT_COMMIT_DST GITHUB_RUN_NUMBER; do
 if test -z "${!it}"; then echo "$it is empty!"; exit 12; fi; done

REPOSITORY=repository
[[ -d "$REPOSITORY" ]] || exit 1 # todo

CODE=0
MESSAGE="Merge ${GIT_COMMIT_SRC::7} -> ${GIT_COMMIT_DST::7} by CI build #${GITHUB_RUN_NUMBER}."
git -C $REPOSITORY commit -m "$MESSAGE"; CODE=$?
if test $CODE -ne 0; then
 echo "Git commit failed!"; exit 41
fi

exit 0
