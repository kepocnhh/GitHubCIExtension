#!/bin/bash

echo "Notification telegram send message..."

. ex/util/args/require $# 1

TELEGRAM_MESSAGE="$1"

. ex/util/require TELEGRAM_BOT_ID TELEGRAM_BOT_TOKEN TELEGRAM_CHAT_ID TELEGRAM_MESSAGE

TELEGRAM_MESSAGE=${TELEGRAM_MESSAGE//"#"/"%23"}
TELEGRAM_MESSAGE=${TELEGRAM_MESSAGE//$'\n'/"%0A"}
TELEGRAM_MESSAGE=${TELEGRAM_MESSAGE//$'\r'/""}
TELEGRAM_MESSAGE=${TELEGRAM_MESSAGE//"_"/"\_"}

CODE=$(curl -s -w %{http_code} -o /tmp/telegram.o \
 "https://api.telegram.org/bot${TELEGRAM_BOT_ID}:${TELEGRAM_BOT_TOKEN}/sendMessage" \
 -d chat_id=$TELEGRAM_CHAT_ID \
 -d text="$TELEGRAM_MESSAGE" \
 -d parse_mode=markdown)

if test $CODE -ne 200; then
 echo "Send message error!"
 cat /tmp/telegram.o
 echo "Request error with response code $CODE!"
 exit 11
fi
