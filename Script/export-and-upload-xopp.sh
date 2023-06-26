#!/bin/bash
PATH_CONFIG="$INSTALL_DIRECTORY/Config/export-and-upload-xopp.config"

PATH_RUNNING="$INSTALL_DIRECTORY/export-and-upload-xopp.tmp"
if [[ -f $PATH_RUNNING ]] ; then
	printf "Already running.\nExit.\n"
	exit 1
else
	touch "$PATH_RUNNING"
	trap "rm -f $PATH_RUNNING" EXIT
fi

# Export all .xopp
printf "Exporting all \".xopp\" files...\n"
xopp-export-all.sh
printf "Completed.\n"

echo "--------------------------------------------------------------------"

printf "Syncing with Google Drive... \n"
while read -r LINE ; do

	if [[ "$LINE" == "#"* ]] ; then continue; fi

	# Tokenize
	OLDIFS="$IFS"

	IFS=';'
	TOKENS=($LINE)
	PATH_SOURCE="${TOKENS[0]}"
	PATH_DEST="${TOKENS[1]}"
	
	IFS=$OLDIFS

	printf "\nSOURCE: \"$PATH_SOURCE\"\nREMOTE: \"$PATH_DEST\"\n"

	# Sync destination to match source
	rclone copy --progress --transfers 8 --checkers 16 --human-readable "$PATH_SOURCE" "$PATH_DEST"

done < "$PATH_CONFIG"

printf "\nCompleted.\n"