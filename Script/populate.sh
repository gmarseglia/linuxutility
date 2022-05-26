# !/bin/bash
: 'Create n files, named file-000x, with the correct zero padding
'

if [[ "$1" == '-h' ]] || [[ "$1" == '--help' ]] ; then
	echo -e "Correct usage: populate.sh FolderToPopulate/ nFiles\nExample: populate.sh target-folder/ 100";
	echo -e "Fill the FolderToPopulate/ with nFiles named file-000x, with the correct 0 padding."
	exit 1
fi

TARGETFOLDER="$1"
NFILES="$2"

#Compute the correct 0 padding
padding=$(echo $NFILES | wc -c)
let padding-=1

#Use 'seq' to produce the sequence of padded indexes
for i in $(seq -f "%0${padding}g" 1 $NFILES); do
	touch "${TARGETFOLDER}file-$i"
done

exit 0