#!/bin/bash

# Directory in which search .xopp and .pdf
TARGET_DIR='/home/giuseppe/UNI'

# Tag for inverted PDF
INVERTED_TAG=" (INVERTED)"
AUTOSAVE_TAG="autosave"

VERBOSE=false
if [[ $1 == '-v' ]] || [[ $1 == '--verbose' ]] ; then VERBOSE=true ; fi

# Using temporary file to store the list of .xopp absolute paths
LIST_PATH=$(mktemp /tmp/export-all-XXXXX)
trap "rm -f $LIST_PATH" EXIT

# Find all ".xopp" paths and store the list in LIST_PATH
find "$TARGET_DIR" -type f -iname "*.xopp" > $LIST_PATH

# Cycle through every found path
while read -r PATH_XOPP;
do
	# Skip autosave files
	if [[ "$PATH_XOPP" == *"autosave"* ]] ; then
		continue
	fi

	# Store the path with ".pdf" extension
	PATH_PDF="${PATH_XOPP%.*}.pdf"

 	if $VERBOSE ; then printf "$PATH_XOPP\n" ; fi

	# If the PDF does not exist OR the ".xopp" is newer than the PDF
	if [ ! -e "$PATH_PDF" ] || [ "$PATH_XOPP" -nt "$PATH_PDF" ] ; then
		if $VERBOSE ; then 
			printf "    \".xopp\" is newer than \".pdf\" OR was never exported --> " ; 
		else
			printf "$PATH_XOPP --> " 
		fi

		# convert the ".xopp" to ".pdf"
		xournalpp -p "$PATH_PDF" "$PATH_XOPP"

		if $VERBOSE ; then printf "    Exported.\n" ; fi
	else
		if $VERBOSE ; then printf "    Already exported.\n" ; fi
	fi

done < $LIST_PATH

# Find all files with .pdf extension and containing the tag $TAG
find "$TARGET_DIR" -type f -iname "*(INVERTED)*.pdf" > $LIST_PATH

while read -r PATH_PDF;
do

	# Get the path of the original .xopp
	PATH_INVERTED_XOPP="${PATH_PDF%.*}.xopp"
	PATH_XOPP="${PATH_INVERTED_XOPP//$INVERTED_TAG/}"
	
	if $VERBOSE ; then printf "$PATH_PDF\n" ; fi

	# If the original .xopp is newer than the .pdf
	if [ "$PATH_XOPP" -nt "$PATH_PDF" ]
	then
		# Invert the original .xopp
		xopp-invert.sh "$INVERTED_TAG" -p "$PATH_XOPP" >/dev/null
		
		# Inverted .xopp to .pdf
		if $VERBOSE ; then
			printf "    Original \".xopp\" is newer than inverted \".pdf\" --> "
		else
			printf "$PATH_PDF --> "
		fi

		xournalpp -p "$PATH_PDF" "$PATH_INVERTED_XOPP"

		if $VERBOSE ; then printf "    Inverted, exported.\n" ; fi

		# Remove the inverted .xopp
		trash "$PATH_INVERTED_XOPP"
	else
		if $VERBOSE ; then printf "    Inverted, already exported.\n" ; fi
	fi

done < $LIST_PATH

if $VERBOSE ; then printf "\nDone.\n" ; fi
