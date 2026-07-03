#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "Error: You must have root privileges to push files."
	exit 1
fi

# Clone autoricer into ./autoricer while maintaining customizations
cd autoricer
if [ ! -d .git ]; then
    git init
    git remote add origin https://github.com/Skimlk/autoricer
fi

git fetch || exit 1
git checkout -f main

# Run autoricer
chmod +x autoricer.sh
./autoricer.sh
