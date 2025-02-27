#!/bin/bash

script=$(realpath "$0")
script_path=$(dirname "$script")
cd "$script_path" || exit 1

USER_HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)

# Define files array with format: "{Filename} {Application Dir} {Dotfiles Dir}"
files=(
	"i3status.conf		/etc/				./i3/"
	"config 		$USER_HOME/.config/i3/		./i3/"
	".bashrc 		$USER_HOME/			./"
	".vimrc			$USER_HOME/			./"
	".xbindkeysrc		$USER_HOME/			./"
	"lxterminal.conf	$USER_HOME/.config/lxterminal/	./"
)

pull() {
	src=$(echo "$file" | awk '{print $2 $1}')
	dest=$(echo "$file" | awk '{print $3}')
}
push() {
	if [ "$EUID" -ne 0 ]; then
		echo "Error: You must have root privileges to push files."
		exit 1
	fi
	src=$(echo "$file" | awk '{print $3 $1}')
	dest=$(echo "$file" | awk '{print $2}')
}

copy_files() {
	if cp $src $dest; then
		echo "Copied '$src' to '$dest'"
	else
		echo "Failed to copy '$src' to '$dest'"
	fi
}

if [ -n "$1" ] && declare -f "$1" > /dev/null; then
	for file in "${files[@]}"; do
		$1
		if [ -n "$(diff $src $dest)" ]; then
			copy_files
		else
			echo "No change to '$src'"
		fi
	done
else
	echo "Error: Incorrect syntax or invalid function."
	echo "Usage: $0 {pull|push}"
	exit 1
fi
