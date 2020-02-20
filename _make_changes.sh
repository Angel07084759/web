#!/bin/bash#!/bin/bash
function toLowerCase() #USE:=$(toLowerCase "$str")
{
	echo "$1" | tr '[:upper:]' '[:lower:]'
}

########### check for files renaming #### START
gitFilesTracked=$(git ls-files)               #
git config core.ignorecase false              #
hasChanged="$(git status --porcelain)"        #
gitFilesUnTracked=$(git ls-files -o)          # get untracked files only
git config core.ignorecase true               #
SAVEIFS=$IFS                                  # Save current IFS
IFS=$'\n'                                     # Change IFS to new line
gitFilesTracked=($gitFilesTracked)            # split to array $names
gitFilesUnTracked=($gitFilesUnTracked)        # split to array $names
IFS=$SAVEIFS                                  # Restore IFS
########### check for files renaming ###### END

date="`date '+%b %d, %Y; %H:%M:%S; %Z'`"

if [[ -n "$hasChanged" ]]
then
	echo "There are changes!";
	read -p "Enter a commit message: " userInput
	
	for fileTracked in "${gitFilesTracked[@]}"
	do
		echo "$fileTracked" ###
		for fileUnTracked in "${gitFilesUnTracked[@]}"
		do
			if [[ "$(toLowerCase "$fileTracked")" == "$(toLowerCase "$fileUnTracked")" ]]
			then
				echo "$fileTracked ==[${#gitFilesTracked[@]}, ${#gitFilesUnTracked[@]}]== $fileUnTracked"
				gitFilesUnTracked=( ${gitFilesUnTracked[@]/"$fileUnTracked"} )
				git rm -f --cached "$fileTracked"
				git add "$fileUnTracked"
				#read -p "Press [Enter]"
				break
			fi
		done
	done
	#read -p "${#gitFilesTracked[@]} ========== ${#gitFilesUnTracked[@]}" #####-----------
	#git ls-files ###
	### Checking for files renaming (case sensitive) ENDS
	
	echo $date>"date"
	git add .
	git commit -m "`date '+%Y-%m-%d %H:%M:%S'` => $userInput"
	git push
	echo "###############################################"
	echo "#              `date '+%Y-%m-%d %H:%M:%S'`           #"
	echo "###############################################"
else
	echo "There are NO changes!";
fi

read -p "Press [Enter] to continue..."

