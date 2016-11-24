#!/bin/bash
clear

names=($@)

if [ -n "$names" ]; then
    for arg in "${names[@]}"; do
	basefname="$(basename $arg)"
	if [ -f "$HOME/dustbin/$basefname" ]; then
	    # File path (existance) check
	    fileToRes="$(grep $basefname "restore.txt")"
	    data="$(<"$HOME/dustbin/$basefname")"
	    # Check for same filename exists on the restore path
	    if [ -f "$fileToRes" ]; then
		$fileToRes="$fileCheck.bak"
	    fi
	    # Restore and Remove
	    sudo mkdir -p $(dirname "$fileToRes")
	    sudo echo "$data" > "$fileToRes"
	    sudo rm "$HOME/dustbin/$basefname"
	fi
	else
	    echo "GerdaleBurdale#1"
    done
else
    echo "GerdaleBurdale#2"
fi
