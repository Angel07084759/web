#!/bin/bash

echo "Deleting Repository History Permanently [$(git config --get remote.origin.url)]"
read -p "Do you want to continue(y/n)?" answer
if [[ $answer != "y" ]]; then 
	echo "Aborting ..."
	read -p "Press Enter to exit.." 
	exit
fi
read -p "Press Enter to Continue.." 

url="$(git config --get remote.origin.url)"

#Remove the history from 
rm -rf .git

#recreate the repos from the current content only
git init
git add .
git commit -m "Initial commit"

# push to the github remote repos ensuring you overwrite history
git remote add origin $url
git push -u --force origin master

read -p "Press [Enter] to continue..."
