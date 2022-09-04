#!/bin/bash

echo "Project prepare..."

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

gradle -p $REPOSITORY clean \
 || . ex/util/throw 11 "Gradle clean error!"

gradle -p $REPOSITORY lib:compileKotlin \
 || . ex/util/throw 12 "Gradle compile error!"
