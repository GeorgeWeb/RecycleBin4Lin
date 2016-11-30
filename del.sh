#!/bin/bash

# Clear the Terminal screen
clear

# Create the 'Trash' directory if it doesn't exist yet
sudo mkdir -p $HOME/dustbin

# Store the console arguments in an array var
names=($@)

# Store the file(path) holding all the "to be deleted" filepaths for a single script execution
temp="$HOME/dustbin/temp.txt"
# Store the file(path) holding all the deleted filepaths in a var
restore="$HOME/dustbin/restore.txt"

# Check for proper usage (if any arguments after the script execution)
if [ -n "$names" ]; then
	# Loop through the array of filename arguments
    for arg in "${names[@]}"; do
		# Get the base file name of the filepath argument specified
		basefname="$(basename "$arg")"
		# Get the full directory path in which the script is stored
		myScriptDir="$(dirname "$(readlink -f $0)")"
		# Get the full argument specified file path 
		# BUT for those specifically inside the script directory
		myScriptDirWithArg="$myScriptDir/$arg"
		# Get the actual full argument specified file path
		argumentDir="$(readlink -f $arg)"
		
		# Store the result of the file file search (by absolute path)
		# Check if the specified filepath is inside the script directory
		# to define the search query
		if [ "ls $myScriptDirWithArg" ==  "ls $argumentDir" ] && [ "$argumentDir" != "$myScriptDir/$basefname" ]; then
			searchByPath="$(find . / -wholename "./$arg" -print 2>/dev/null)"
		else
			searchByPath="$(find . / -wholename "$arg" -print 2>/dev/null)"
		fi
		# Store the result the file search (by name, anywhere)
		searchByName="$(find . / -name "$arg" -type f -print 2>/dev/null | sudo tee "$temp")"
		
		# Search file in the /root/ directory (and all sub-directories) by name
		if [ -n "$searchByName" ];  then
			# For convinience delete the non-relevant relative paths
			# to avoid duplicated file paths
			grep -v '^./' "$temp" | sudo tee "$temp" && grep -v '^/initrd/pup_rw' "$temp" | sudo tee "$temp"; clear
			echo "Finding all instances of files named \"$basefname\": ..."
			# Read through the temp file lines so you can have the chance to 
			# delete a specific file with that name (if many)
			while read file <&9; do
				# Check if there is the same filename 
				# in the Dustbin directory already
				if [ "$file" == "$HOME/dustbin/$basefname" ]; then
					echo "Found a file with the same name that is already in the Dustbin."
				else
					# Ask to delete/or not the specified file
					echo -n "Delete file \"$file\" ?" "[Y/n] "; read opt
					case $opt in
					Y|y|Yes|yes)# Yay
						clear
						# move file to trash directory
						grep "$file" "$temp" | sudo tee "$restore"; clear
						sudo mv "$file" "$HOME/dustbin"
						echo "\"$file\" trashed successfully.";;
					N|n|No|no)# Nay
						clear
						echo "Well, maybe next time.";;
					*)  # Sorry, wrong input
						clear
						echo "\"$option\" is an invalid option. Press ENT to continue"
						read enterKey
						exit;;
					esac
				fi
			done 9< "$temp"
		# Search file in the /root/ directory (and all sub-directories) by path
		elif [ -n "$searchByPath" ]; then
			# Ask to delete/or not the specified file
			echo -n "Delete file \"$arg\" ?" "[Y/n] "; read opt
			case $opt in
			Y|y|Yes|yes) # Yay
				clear
				# move file to trash directory
				readlink -f "$arg" | sudo tee "$restore"
				sudo mv "$arg" "$HOME/dustbin"
				echo "\"$arg\" trashed successfully.";;
			N|n|No|no)# Nay
				clear
				echo "Well, maybe next time.";;
			*)  # Sorry, wrong input
				clear
				echo "\"$option\" is an invalid option. Press ENT to continue"
				read enterKey
				exit;;
			esac
		else
			echo "No such file exists."
		fi
    done
    # Remove the temporary path storing file after script exection file
    if [ -f "$temp" ]; then
		sudo rm "$temp"
    fi
else
	# Wrong usage error message
    echo "Usage: del \"filepath\""
fi
