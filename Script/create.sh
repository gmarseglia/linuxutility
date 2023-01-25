# !/bin/bash

#Help
if [[ $1 == '-h' ]] || [[ $1 == '-h' ]] ; then
	printf "Correct usage:
	$(basename $0)
	$(basename $0) basename\n"
	printf "Behavior:
	Create a file called ""basename"" (if basename not given, a basename is asked),
	'touch' the file and give correct permission.\n"
	exit 1;
fi

#If an argument is not given, ask for a basename
if [[ -z $1 ]]; then
	printf "Insert bash basename:\n"
	read basename
#Else use argument as basename
else
	basename="$1"
fi
name="$PWD/$basename.sh"

printf "Creating $name\n"
touch "$name"
printf "#!/bin/bash\n" >> "$name"
chmod +rx "$name"

exit 0
