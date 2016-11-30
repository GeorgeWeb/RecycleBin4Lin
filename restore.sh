#!/bin/bash

# Clear the Terminal screen
clear

# Store the console arguments in an array var
names=($@)

# Store the file(path) holding all the deleted filepaths to that moment in a var
restore="$HOME/dustbin/restore.txt"

# Check for proper usage (if any arguments after the script execution)
if [ -n "$names" ]; then
	# Loop through the array of filename arguments
    for arg in "${names[@]}"; do
		# Store the base file name of the filepath argument
		basefname="$(basename $arg)"
		if [ -f "$HOME/dustbin/$basefname" ]; then
			# File path (existance) check
			fileToRes="$(grep -m 1 $arg $restore)"
			# Store the data(in var) of the file in the dustbin for restore
			data="$(<"$HOME/dustbin/$basefname")"
			# Check for same filename exists on the restore path
			if [ -f "$fileToRes" ]; then
				fileToRes="$fileToRes.bak"
			fi
			# Make the required directories to the file (if any needed at all)
			sudo mkdir -p $(dirname "$fileToRes")
			# Create the file with its data(it had before deletion
			sudo echo "$data" > "$fileToRes"
			# Remove the file from the dustbin
			sudo rm "$HOME/dustbin/$basefname"
			# The operation will seem like actual moving 
			# even though it is a CREATE -> REMOVE one
		else
			# File non-existance error message
			echo "No such file in the Dustbin."
			echo "Have a look at the filename and give it another go."
		fi
    done
else
	# Wrong usage error message
    echo "Usage: \"restore\" filepath"
fi
