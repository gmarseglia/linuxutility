# !/bin/bash
: '
Find NON recursively all the files in a folder, create n subfolders, and put the files in order into the subfolders.
TODO list:
	Solve problem when more subfolders than files
	Solve problem when subfolders already exist
'
#Help
function correctUsagePrint {
	printf "Correct usage:
	$(basename $0) dirToSplit/ nOfSubdirectories"
}
if [[ $1 == '-h' ]] || [[ $1 == '--help' ]] ; then
	correctUsagePrint
	printf "Behavior:
	Find all the files in dirToSplit/ NON recursively,
	create nOfSubdirectories in dirToSplit/,
	put evenly the file in these sub-directories,
	a report is produced.\n"
	exit 0;
fi

#Renamed arguement
DIRSPLIT="$1"
NSUBFOLDERS="$2"

#Error: missing folder
if [[ ! -d "$DIRSPLIT" ]] ; then
	printf "Error: missing folder.\n$(correctUsagePrint)\nTerminating.\n"
	exit -1;
fi

#Error: argument $2 is not an integer
re='^[0-9]+$'
if ! [[ "$NSUBFOLDERS" =~ $re ]] ; then
	printf "nOfSubdirectories must be an integer.\n$(correctUsagePrint)\nTerminating.\n"
	exit -1;
fi

#Function to remove the temporary files created, and exit with code passede as argument
function clearTmpAndClose {
	rm $FILELIST $SORTEDFILELIST $MOVELIST
	exit $1
}

DIRSPLITBASENAME=$(basename $DIRSPLIT)
REPORTFILE="${DIRSPLIT}report-of-${DIRSPLITBASENAME}.out"

FILELIST=$(mktemp)
SORTEDFILELIST=$(mktemp)
MOVELIST=$(mktemp)

#Finds all the file in $1 NON recursively, and store the result in a temporary file called FILELIST
find "$DIRSPLIT" -maxdepth 1 -type f > $FILELIST

#Counts the line in FILELIST and ask the users if they want to procede. On not confirm it exits.
NTOTALFILES=$(wc -l  < "$FILELIST")

#Compute the number of files to be put in each sub folder
let nRemainder=$NTOTALFILES%$NSUBFOLDERS
let nSubUnit=$NTOTALFILES/$NSUBFOLDERS
#If the number of files is not at multiple of the number of the subfolders, make the the number of files in each subfolder 1 more
if [[ ! $nRemainder -eq 0 ]]; then
	let nSubUnit+=1;
fi

#User confirm
printf "Found $NTOTALFILES files. $NSUBFOLDERS folders containg (at most) $nSubUnit files each will be created.\nProceed? (y/n)\n"
read response
if [[ ! $response == 'y' ]] && [[ ! $response == 'Y' ]] ; then
	printf "Terminating.\n"
	clearTmpAndClose 1;
fi

#Sort the file list, this can be changed to sort the files differently
sort $FILELIST > $SORTEDFILELIST

#Compute the length of the 0 for the padding
nPadding=$(printf $NSUBFOLDERS | wc -c)
let nPadding-=1
#Main cycle, for(int i=1; i <= NSUBFOLDERS; i++)
i=1
while [[ $i -le $NSUBFOLDERS ]]; do
	#Create the subfolder, with 0 padded name
	paddedIndex=$(printf "%0${nPadding}d" $i)
	targetSubfolder="${DIRSPLIT}subfolder-${paddedIndex}-of-$DIRSPLITBASENAME"
	mkdir $targetSubfolder

	#Compute the first and last index of the files that have to go into the subfolder
	let x=$i-1
	let nFirstFile=$nSubUnit*$x+1
	let nLastFile=$nFirstFile+$nSubUnit-1

	#Fill $MOVELIST with the file to be moved, in this case done with 'sed'
	#tail $SORTEDFILELIST -n +$nFirstFile | head -n $nSubUnit > $MOVELIST
	sed -n "$nFirstFile,${nLastFile}p" $SORTEDFILELIST > $MOVELIST

	#Move the files contained in $MOVELIST, and append to $REPORTFILE
	while read file; do
		printf "$file $targetSubfolder\n" >> $REPORTFILE
		mv "$file" "$targetSubfolder"
	done < $MOVELIST

	#If the number of file or the number of subfolders are big, an echo showing the progess is added
	if [[ $NSUBFOLDERS -gt 10 ]] | [[ $NTOTALFILES -gt 100 ]] ; then
		printf "$i/$NSUBFOLDERS done\n";
	fi

	let i+=1;
done

clearTmpAndClose 0