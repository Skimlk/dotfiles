#!/bin/bash

script=$(realpath "$0")
script_path=$(dirname "$script")
cd "$script_path" || exit 1

USER_HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)

# Define files array with format: "{Application Name} {Filename} {Application Dir} {Dotfiles Dir}"
files=(
	"i3		i3status.conf		/etc/				./i3/"
	"i3		config 		$USER_HOME/.config/i3/		./i3/"
	"bash		.bashrc 		$USER_HOME/			./"
	"vim		.vimrc			$USER_HOME/			./"
	"xbindkeys	.xbindkeysrc		$USER_HOME/			./"
	"lxterminal	lxterminal.conf		$USER_HOME/.config/lxterminal/	./"
)

pull() {
	src=$(echo "$file" | awk '{print $3 $2}')
	dest=$(echo "$file" | awk '{print $4}')
}
push() {
	if [ "$EUID" -ne 0 ]; then
		echo "Error: You must have root privileges to push files."
		exit 1
	fi
	src=$(echo "$file" | awk '{print $4 $2}')
	dest=$(echo "$file" | awk '{print $3}')
}

copy_files() {
	if cp $src $dest; then
		echo "Copied '$src' to '$dest'"
	else
		echo "Failed to copy '$src' to '$dest'"
	fi
}

operate() {
	$operation
	if [ -n "$(diff $src $dest)" ]; then
		copy_files
	else
		echo "No change to '$src'"
	fi
}

operation=$1
if [ -n "$operation" ] && declare -f "$operation" > /dev/null; then
	if [ -n "$2" ]; then
		arg_files=()
		for arg in "${@:2}"; do 
			for line in "${files[@]}"; do
				if [ $(echo $line | grep -Eo '^[^ ]+') == $arg ]; then
					arg_files+=("$line")
				fi
			done
		done
		files=("${arg_files[@]}")
	fi

	for file in "${files[@]}"; do
		operate
	done
else
	echo "Error: Incorrect syntax or invalid function."
	echo "Usage: $0 {pull|push} {application}"
	exit 1
fi
