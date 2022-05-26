# !/bin/bash

#Help
function correctUsagePrint {
	printf "Correct usage:
	$(basename $0) dirToScan/ dirWithExistingFile/ dirToPutFoundDuplicates/\n"
	
}
if [[ $1 == '-h' ]] || [[ $1 == '--help' ]]; then
	correctUsagePrint
	printf "Behavior:
	Find recursively all the files in dirToScan/,
	for each file in dirToScan/ find recursively files with the same basename in dirWithExistingFile/,
	if a file is found, then move the file from dirToScan/ to dirToPutFoundDuplicates/,
	a report is produced.\n"
	exit 1;
fi

#Error: missing directory
if [[ ! -d "$1" ]] || [[ ! -d "$2" ]] || [[ ! -d "$3" ]]; then
	printf "Error:
	Missing directory.\n"
	correctUsagePrint
	exit -1
fi

#Renamed argument
DIRSCAN="$1"
DIREXIST="$2"
DIRPUT="$3"

#Variables and temporary file declaration
DIRSCANBASENAME=$(basename $DIRSCAN)
REPORTFILE="report-of-${DIRSCANBASENAME}.out"

FILELIST=$(mktemp)
DUPLICATESLIST=$(mktemp)
NONDUPLICATESLIST=$(mktemp)
EXTENDEDDUPLICATESLIST=$(mktemp)

nTotalFiles=0
nMovedFiles=0

function clearTmpAndClose {
	#Remove the temporary file used
	rm $FILELIST $DUPLICATESLIST $NONDUPLICATESLIST $EXTENDEDDUPLICATESLIST
	exit $1
}

#Finds all the file in $1 recursively, and store the result in a temporary file called FILELIST
find "$DIRSCAN" -type f > $FILELIST

#Counts the line in FILELIST and ask the users if they want to procede. On not confirm it exits.
nTotalFiles=$(wc -l  < "$FILELIST")
if [[ $nTotalFiles == '0' ]]; then
	printf "No file found in ${DIRSCAN}\nTerminating.\n"
	clearTmpAndClose 1;
fi
printf "Found $nTotalFiles files. Proceed? (y/n)\n"
read response
if [[ ! $response == 'y' ]] && [[ ! $response == 'Y' ]] ; then
	printf "Terminating.\n"
	clearTmpAndClose 1
fi

printf "Report of: $(basename $0) $DIRSCAN $DIREXIST $DIRPUT\n" >> $REPORTFILE

#While used to read line per line from FILELIST
counter=0

while read filename; do

	let counter+=1

	#Get the truncated filename (without directory), in order to find it in $2
	basename=$(basename "$filename")

	printf "[$counter/$nTotalFiles]\t'$filename'\t"

	#Find in $DIREXIST using the basename and store the result
	findResult=$(find $DIREXIST -name "$basename")

	if [ "$findResult" ] ; then
		#Executed when a duplicate is found

		printf "Duplicate\n"

		#Move the file from $1 to $DIRPUT
		mv "$filename" "$DIRPUT" 
		let nMovedFiles+=1

		printf "$filename\n" >> $DUPLICATESLIST
		printf "\t$filename:\n" >> $EXTENDEDDUPLICATESLIST
		printf "$findResult\n\n" >> $EXTENDEDDUPLICATESLIST;
	else
		#Executed when duplicate NOT found

		printf "Not found\n"
		printf "$filename\n" >> $NONDUPLICATESLIST;
	fi;

#Output is shown on stdout and copied to REPORTFILE (done with command tee)
done < $FILELIST

printf "\nNon duplicates:\n$(cat $NONDUPLICATESLIST)\n" >> $REPORTFILE

#Info about duplicates are addede to REPORTFILE only if DUPLICATESLIST contains at least one entry
if [[ $(wc -l < $DUPLICATESLIST) > 0 ]] ; then
	printf "\nDuplicates:\n$(cat $DUPLICATESLIST)\n" >> $REPORTFILE

	printf "\nExtended duplicates:\n$(cat $EXTENDEDDUPLICATESLIST)\n" >> $REPORTFILE
fi

printf "\nFrom a total of $nTotalFiles files, $nMovedFiles files have been moved.\n" | tee -a $REPORTFILE

clearTmpAndClose 0