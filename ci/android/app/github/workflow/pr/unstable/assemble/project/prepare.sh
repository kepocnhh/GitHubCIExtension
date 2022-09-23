#!/bin/bash

echo "Workflow pr unstable assemble project prepare start..."

mkdir -p assemble/project || exit 11
ex/android/app/project/sign/prepare.sh || exit 12
ex/android/app/project/prepare.sh || exit 13
ex/android/app/project/assemble/common.sh || exit 14
