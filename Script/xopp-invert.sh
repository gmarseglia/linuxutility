#!/bin/bash

#If an argument is not given, ask for a basename or path
if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] || ( [[ ! $2 == "-b" ]] && [[ ! $2 == "-p" ]] ) ; then
	printf "Incorrect. Correct usage: xopp-invert.sh invertedTag -b|-p baseName|path\nExit.\n"
	exit 1
else
	TAG="$1"

	if [ $2 == "-b" ] ; 
	then
		BASENAME="$3"
		PATH_XOPP="$PWD/$BASENAME"
	fi

	if [ $2 == "-p" ] ; 
	then
		PATH_XOPP="$3"
	fi

fi

printf "Target: $PATH_XOPP\n"

# Step 0: check if file is already inverted
if [[ "$PATH_XOPP" == *"$TAG"* ]] ; then
	printf "    \"$PATH_XOPP\" already inverted. Done.\n"
	exit 0
fi

# Step 1: copy and rename to PATH_XOPP.gz
PATH_GZ="${PATH_XOPP%.*}.gz"
cp "$PATH_XOPP" "$PATH_GZ"

# Step 2: decompress via gzip
PATH_XML="${PATH_XOPP%.*}"
gzip -df "$PATH_GZ"

# Step 3: Change colors via sed
# White -> Black
sed -i 's/#ffffffff/#000000ff/g' "$PATH_XML"
# Dark Grey -> White
sed -i 's/#0e0e0eff/#ffffffff/g' "$PATH_XML"
# Light Green -> Dark Green
sed -i 's/#00ff00ff/#008000ff/g' "$PATH_XML"
# Light Blue -> Blue
sed -i 's/#00c0ffff/#3333ccff/g' "$PATH_XML"

# Step 3: compress zia gzip
gzip "$PATH_XML"

# Step 4: rename adding tag
mv "$PATH_GZ" "$PATH_XML$TAG.xopp"

printf "    Done.\n"