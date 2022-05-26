# !/bin/bash

#Help
function correctUsagePrint {
	printf "Correct usage:
	$(basename $0) [-n nSeconds] [-r nRepetitions] command\n"
}
if [[ $1 == '-h' ]] || [[ $1 == '--help' ]]; then
	correctUsagePrint
	printf "Behavior:
	Checks if options are given,
	then run the 'command' every 'nSeconds' (default is 1),
	(if given) after 'nRepetitions' times stops running the 'command'\n"
	exit 1;
fi

#Check if first argument $1 is an int, if not use second argument $2 to print an error message
function integerCheck {
	re='^[0-9]+$'
	if ! [[ "$1" =~ $re ]] ; then
		printf "Error:\n\t$2 must be an integer.\n$(correctUsagePrint)\nTerminating.\n"
		exit -1;
	fi
}

#Variables declaration
command=""
seconds=1
repetitions=-1
optionCheck='true'

#While cycle, with case, to check if options are given
#'Shift' exclude the options arguments from the command arguments
while [[ $optionCheck == 'true' ]]; do
	case "$1" in
		'-n' | '--nseconds')
			seconds="$2"
			integerCheck $seconds "nSeconds"
			shift
			shift
			;;

		'-r' | '--repetitions')
			repetitions="$2"
			integerCheck $repetitions "nRepetitions"
			shift
			shift
			;;

		*)
			optionCheck='false'
			;;
	esac;
done

#Concatenate all the command arguments in a single string
for i in "$@"; do
	command="${command} $i"
done

#Main while cycle, clear the terminal, run the command, and then sleeps for 'nSeconds'
#If repetitions is greater than 0, it means that 'nRepetitions' is given, and so there is a check
while [[ $repetitions -gt 0 ]] || [[ $repetitions -eq -1 ]]; do
	clear
	printf "$(date), "
	if [[ $repetitions -gt 0 ]]; then
		let repetitions-=1;
		printf "'$command' every $seconds seconds, remaining repetitions ${repetitions}:\n"
	else
		printf "'$command' every $seconds seconds:\n";
	fi
		$command
	sleep $seconds;
done
