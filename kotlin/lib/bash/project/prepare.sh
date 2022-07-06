#!/bin/bash

echo "Project prepare..."

gradle -p repository clean \
 || . ex/util/throw 11 "Gradle clean error!"

gradle -p repository lib:compileKotlin \
 || . ex/util/throw 12 "Gradle compile error!"

exit 0
