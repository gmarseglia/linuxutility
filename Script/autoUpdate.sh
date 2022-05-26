# !/bin/bash

#Help
if [[ "$1" == '-h' ]] || [[ "$1" == '--help' ]] ; then
	printf "Correct usage:\n\t$(basename $0)\n"
	printf "Behavior:
	Run 'sudo apt update' and then if there are upgradable packages run 'sudo apt upgrade', sudo apt autoclean', 'sudo apt autoremove'\n"
	exit 1;
fi

#Variables and temporary files declaration
DIVIDER="-----------------------------"
OUTPUTSTORE=$(mktemp)

#Functions declaration
function printDivider {
	printf -- "$DIVIDER\n"
}

#Ask for sudo password
sudo echo -n

#Call 'sudo apt update -y', to check if there are upgradable packages, and store the output in $OUTPUTSTORE with 'tee'
printf -- "$DIVIDER\nChecking updates\n$DIVIDER\n"
sudo apt update -y 2>/dev/null | tee $OUTPUTSTORE
printDivider

#Check if the output of 'sudo apt update' contains 'apt list --upgradable', which means that there are upgradable packages
#	also check if option '-a' or '--all' are given
if [[ $(cat $OUTPUTSTORE)  == *'apt list --upgradable'* ]] || [[ $1 = "-a" ]] || [[ $1 = "--all" ]] ;
then
	printf "Upgrading and cleaning\n${DIVIDER}\n"
	for opt in upgrade autoclean autoremove; do 
		printf "sudo apt $opt -y\n${DIVIDER}\n"
		sudo apt $opt -y
		printDivider; 
	done
fi

#Print the current storage used on all ext4 filesystem
printf "Done. Memory status:\n%s\n$DIVIDER\n" "$(df -h -t ext4 -t fuseblk)"

rm $OUTPUTSTORE
exit 0
