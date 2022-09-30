#!/bin/bash

echo "Notification telegram send message..."

. ex/util/args/require $# 1

TELEGRAM_MESSAGE="$1"

. ex/util/require TELEGRAM_BOT_ID TELEGRAM_BOT_TOKEN TELEGRAM_CHAT_ID TELEGRAM_MESSAGE

TELEGRAM_MESSAGE=${TELEGRAM_MESSAGE//"#"/"%23"}
TELEGRAM_MESSAGE=${TELEGRAM_MESSAGE//$'\n'/"%0A"}
TELEGRAM_MESSAGE=${TELEGRAM_MESSAGE//$'\r'/""}
TELEGRAM_MESSAGE=${TELEGRAM_MESSAGE//"_"/"\_"}

OUTPUT=/tmp/output
CODE=0
CODE=$(curl -s -w %{http_code} -o $OUTPUT \
 "https://api.telegram.org/bot${TELEGRAM_BOT_ID}:${TELEGRAM_BOT_TOKEN}/sendMessage" \
 -d chat_id=$TELEGRAM_CHAT_ID \
 -d text="$TELEGRAM_MESSAGE" \
 -d parse_mode=markdown)

if test $CODE -ne 200; then
 echo "Send message error!"
 echo "Request error with response code $CODE!"
 cat $OUTPUT
 exit 11
fi
