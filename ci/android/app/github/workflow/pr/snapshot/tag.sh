#!/bin/bash

VERSION_NAME=$(ex/util/jqx -sfs assemble/project/common.json .version.name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
VERSION_CODE=$(ex/util/jqx -si assemble/project/common.json .version.code) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
TAG="${VERSION_NAME}-${VERSION_CODE}-SNAPSHOT"
