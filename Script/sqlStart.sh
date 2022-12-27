# !/bin/bash

#Help
if [[ "$1" == '-h' ]] || [[ "$1" == '--help' ]] ; then
	printf "Correct usage:\n\t$(basename $0)\n"
	printf "Behavior:
	Restart mysql.service and apache2.service\n"
	exit 1;
fi

#Ask for sudo password
sudo echo -n

#Variables and temporary files declaration
DIVIDER="-----------------------------"

#Functions declaration
function printDivider {
	printf -- "$DIVIDER\n"
}

#Restart mysql.service
printf -- "$DIVIDER\nRestarting mysql.service\n$DIVIDER\n"
sudo systemctl restart mysql.service
sudo systemctl list-units | grep mysql
printDivider

#Restart apache2.service
printf -- "$DIVIDER\nRestarting mysql.service\n$DIVIDER\n"
sudo systemctl restart apache2.service
sudo systemctl list-units | grep apache2
printDivider

printf "Done.\n"

exit 0
