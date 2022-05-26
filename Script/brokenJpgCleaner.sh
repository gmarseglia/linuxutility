# !/bin/bash

#Help
function helpPrint {
	printf "Correct usage:\n\t$(basename $0) directoryToScan/ directoryToPutBroken/\n"
	printf "Behavior:
	Find recursively all the files terminating in '.jpg' or '.jpeg' (case unsensitive) in directoryToScan/,
	run 'jpeginfo' on these files,
	if 'jpeginfo' finds an ERROR or a WARNING move the file in directoryToPutBroken/,
	a report is produced.\n"
}

if [[ $1 == '-h' ]] || [[ "$1" == '--help' ]] ; then
	helpPrint
	exit 1
fi

#Renamed argument
DIRSCAN="$1"
DIRPUT="$DIRPUT"

#Error: missing directory
if [[ ! -d "$DIRSCAN" ]] || [[ ! -d "$DIRPUT" ]]; then
	printf "Error:
	Missing directory\n$(helpPrint)\nTerminating.\n"
	exit -1;
fi

#Variables and temporary files declaration
FILELIST=$(mktemp)
ERRORLIST=$(mktemp)
MOVELIST=$(mktemp)
REPORTFILE="report-of-$(basename $DIRSCAN).out"

function clearTmpAndClose {
	rm "$FILELIST" "$ERRORLIST" "$MOVELIST"
	exit $1
}

#Find all the files termitaing in .jpg or .jpeg
find $DIRSCAN -iname "*.jpg" -or -iname "*.jpeg" > $FILELIST

#Count found files and ask user for confirmation
nTotalFiles=$(wc -l  < "$FILELIST") 
printf "Found $nTotalFiles files. Proceed? (y/n)\n"
read response
if [[ ! $response == 'y' ]] && [[ ! $response == 'Y' ]] ; then
	printf "Terminating.\n"
	clearTmpAndClose 1
fi

#Analyze with 'jpeginfo' all the found files and put in $ERRORLIST if they present WARNING or ERROR
analyzedFiles=0
while read file; do
	jpeginfo "$file" | grep 'ERROR\|WARNING' >> $ERRORLIST
	let analyzedFiles+=1
	printf "Analyzed [$analyzedFiles/$nTotalFiles] files\n";
done < $FILELIST

#Get only the filename from the output of 'jpeginfo'
while read line; do
	printf "$line" | awk '{print $1;}' >> $MOVELIST;
done < $ERRORLIST

#Count the file to move and move them
nMoveFiles=$(wc -l  < "$ERRORLIST") 
printf "Found $nMoveFiles files to move to $DIRPUT.\n"
movedFiles=0
while read file; do
	let movedFiles+=1
	printf "Moving $file [$movedFiles/$nMoveFiles] to $DIRPUT\n"
	mv "$file" "$DIRPUT";
done < $MOVELIST

#Produce the REPORTFILE
printf "File moved:\n" > $REPORTFILE
cat "$MOVELIST" >> $REPORTFILE

clearTmpAndClose 0