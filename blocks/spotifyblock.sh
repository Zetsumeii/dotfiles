#!/bin/bash

if ! pgrep -x "spotify" > /dev/null; then
    echo "Spotify is not running."
    exit 1
fi

metadata=$(playerctl -p spotify metadata --format '{{title}} {{artist}}')


if [ "$(playerctl -p spotify status)" == "Paused" ]; then
    echo $metadata 󰏤
else
    echo $metadata 󰝚
fi
