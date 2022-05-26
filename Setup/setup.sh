#
#	Esegue il setup dell'ambiente di Linux
#

THIS_PATH=$(pwd)
INSTALLDIRECTORY=$(builtin cd "$THIS_PATH/.."; pwd)
WORKSPACEDIRECTORY="$HOME/Workspace"

CUSTOMBINDIRECTORY="$INSTALLDIRECTORY/Script"
CUSTOMCOMMANDSFILE="$INSTALLDIRECTORY/Setup/customCommands"
MOREBASHRC="$INSTALLDIRECTORY/Setup/moreBashrc"

if [ -a ~/.bashrc ] ;
	then
		echo "Setup iniziato.";
	else
		"$HOME/.bashrc non esiste." && exit 1;
fi

#	Aggiunge a .bashrc una stringa di inizio modifiche
printf "\n###INZIO MODIFICHE DOVUTE A setup.sh\n" >> $HOME/.bashrc

#	Aggiunge a .bashrc la cartella MegaSync al PATH per l'esecuzione dei bin custom, determinato dalle variabili
printf "\n#Directory di MegaSync per l'esecuzione dei bin custom\n" >> $HOME/.bashrc
#echo export PATH='$PATH':$CUSTOMBINDIRECTORY >> $HOME/.bashrc
printf "export PATH="'$PATH'":$CUSTOMBINDIRECTORY\n" >> $HOME/.bashrc

#	Rende eseguibili tutti i bin custom nella CustomBinDirectory
chmod a+x $CUSTOMBINDIRECTORY/*

#	Aggiunge a .bashrc i comandi costum contenuti nel file CustomCommandsFile
echo -e "\n#Comandi Custom" >> $HOME/.bashrc
while read customcommand; do printf "alias $customcommand\n" >> ~/.bashrc; done < $CUSTOMCOMMANDSFILE
printf "\n" >> $HOME/.bashrc

#	Appende a .bashrc il contenuto del file morebashrc.txt
cat $MOREBASHRC >> $HOME/.bashrc

#	Aggiunge a .bashrc una stringa di fine modifiche
printf "\n###FINE MODIFICHE DOVUTE A setup.sh\n" >> ~/.bashrc

#	Rende il completion della bash case insensitive per l'utente
#	https://askubuntu.com/questions/87061/can-i-make-tab-auto-completion-case-insensitive-in-bash
if [ ! -a ~/.inputrc ]; then echo '$include /etc/inputrc' > ~/.inputrc; fi
echo 'set completion-ignore-case On' >> ~/.inputrc

#	Aggiunge un link alla InstallDirectory nella directory principale
if [ ! -d ~/Linux ]; then ln -s $INSTALLDIRECTORY ~; fi

#	Crea la cartella Workspace se non esiste
if [ ! -d $WORKSPACEDIRECTORY ] ;
	then mkdir $WORKSPACEDIRECTORY;
fi

#	Aggiunge il file ~/.dircolors per risolvere problema colorazione NTFS
#	https://askubuntu.com/questions/208345/dircolors-ls-not-being-displayed-correctly-under-ntfs-drive
cp "$INSTALLDIRECTORY/Setup/dircolors" "$HOME/.dircolors"

echo "Setup completato. Riavvia la shell."
