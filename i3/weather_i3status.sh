#!/bin/sh
# shell script to prepend i3status with more stuff

i3status -c /home/skim/.config/i3/i3status.conf | while :
do
	read line
	weather=$(curl https://wttr.in/?format=%l:+%c+%t | sed 's/  */ /g')

	if [ -z "$weather" ]; then
		weather="Weather Unavailable"
	fi

	echo "$weather | $line" || exit 1
done
