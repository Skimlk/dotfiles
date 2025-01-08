#!/bin/bash

script=$(realpath "$0")
script_path=$(dirname "$script")
cd "$script_path" || exit 1

# Define files array with format: "{Filename} {Application Dir} {Dotfiles Dir}"
files=(
	"i3status.conf		/etc/						./i3/"
	"config 			$HOME/.config/i3/			./i3/"
	".bashrc 			$HOME/						./"
	".vimrc				$HOME/						./"
	".xbindkeysrc		$HOME/						./"
	"lxterminal.conf	$HOME/.config/lxterminal/	./"
)

pull() {
	src=$(echo "$file" | awk '{print $2 $1}')
	dest=$(echo "$file" | awk '{print $3}')
}
push() {
	src=$(echo "$file" | awk '{print $3 $1}')
	dest=$(echo "$file" | awk '{print $2}')
}

if [ -n "$1" ] && declare -f "$1" > /dev/null; then
	for file in "${files[@]}"; do
		$1
		if cp $src $dest; then
			echo "Copied '$src' to '$dest'"
		else
			echo "Failed to copy '$src' to '$dest'"
		fi
	done
else
	echo "Error: Incorrect syntax or invalid function."
	echo "Usage: $0 {pull|push}"
	exit 1	
fi
