#!/bin/bash

. ex/util/json -f assemble/project/common.json \
 -sfs .version.name VERSION_NAME \
 -si .version.code VERSION_CODE

TAG="${VERSION_NAME}-${VERSION_CODE}-STAGING"
