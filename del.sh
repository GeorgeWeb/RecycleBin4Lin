#!/bin/bash
clear

# create the trash directory if it doesn't exist yet
sudo mkdir -p $HOME/dustbin

names=($@)

storage="temp.txt"
clear="clear.txt"
restore="restore.txt"

if [ -n "$names" ]; then
# loop through the (files) arguments
for arg in "${names[@]}"; do
    basefname="$(basename "$arg")"
    searchByPath="$(find . / -wholename "$arg" -print 2>/dev/null | sudo tee "$storage")"
    searchByName="$(find . / -name "$arg" -type f -print 2>/dev/null | sudo tee "$storage")"
    
    # search file in the system by file name
    if [ -n "$searchByName" ];  then
	# for convinience delete the relatives to avoid duplicated file paths
	echo "Finding all instances of files named \"$basefname\":"
	echo "$storage" > "$clear"
	sudo grep -v '^./' "$storage" > "$clear"
	while read file <&9; do
	    echo "File: $file"
	    if [ "$file" == "$HOME/dustbin/$basefname" ]; then
		echo "This instance of the file you are looking at is already in the Trash."
	    else
		echo -n "Are you sure you want to delete this exact file ?" "[Y/n] "; read opt
		case $opt in
		    Y|y)# Yay
			clear
			# move file to trash directory
			grep "$file" "$clear" >> "$restore"
			sudo mv "$file" "$HOME/dustbin"
			echo "File trashed successfully.";;
		    N|n)# Nay
			clear
			echo "Well, maybe next time.";;
		    *)  # Sorry, wrong input
			clear
			echo "$option is an invalid option. Press ENT to continue"
			read enterKey
			exit;;
		esac
            fi
	done 9< "$clear"
    # search file in the system by path
    elif [ -n "$searchByPath" ]; then
	echo -n "Are you sure you want to delete this file \"$arg\" ?" "[Y/n] "; read opt
	case $opt in
	    Y|y)# Yay
		clear
		# move file to trash directory
		sudo grep "$arg" "$store" >> "$restore"
		sudo mv "$arg" "$HOME/dustbin"
		echo "File trashed successfully.";;
	    N|n)# Nay
		clear
		# ERASE PATH FROM RESTORE.TXT
		echo "Well, maybe next time.";;
	    *)  # Sorry, wrong input
		clear
		echo "$option is an invalid option. Press ENT to continue"
		read enterKey
		exit;;
	esac
    else
	echo "No such file or directory exists."
    fi
done
else
    echo "No file arguments were used after the \"del\" command. Please do specify such."
fi
