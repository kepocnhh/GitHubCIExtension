#!/bin/bash

echo "Workflow pr snapshot assemble project prepare start..."

mkdir -p assemble/project \
 || . ex/util/throw 11 "Illegal state!"

ex/util/run/pipeline \
 ex/android/app/project/sign/prepare.sh \
 ex/android/app/project/prepare.sh \
 ex/android/app/project/assemble/common.sh || exit 21
