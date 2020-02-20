#!/bin/bash

imageExtensions=(png jpg gif)				#tif Notsupported
videoExtensions=(mp4 webm ogg)				#
imagesDirectories=(images)                  #directoris and names should not contain spaces
videosDirectories=(videos)                  #

function toLowerCase() #USE:=$(toLowerCase "$str")
{
	echo "$1" | tr '[:upper:]' '[:lower:]'
}

function checkRootPathName() #USE:=$(checkRootPathName "$dir")
{
	temp=$1
	for file in *
	do
		if [[ "$(toLowerCase "$file")" == "$(toLowerCase "$temp")" ]]
		then
			temp=$file
			break
		fi
	done
	echo $temp
}

function processMediaFiles() #"$1" == "" ? "*" : "$1"/*
{
	if [[ -d "$1" ]] #if arg is a dir, create a data file with the same name
	then
		file="$1/$(basename -- "$1")"
		rm "$file" 
		>"$file" 
	fi
	
	arg="$1"
	wildcard=/*
	shift
	extensions=($@)
	if [[ -z "$arg" ]]; then wildcard=*; fi
	

	for file in "$arg"$wildcard
	do
		if [[ -d "$file" ]]
		then
			pathTxt="$file/$(basename -- "$file")"
			>$pathTxt
			
			#read -p "[$file >> $(basename -- "$file")]" ###
			processMediaFiles "$file" ${extensions[@]}
		else
			#echo "=>$file [${extensions[@]}]"
			fullPath=$file
			pathOnly=$(dirname "${fullPath}")
			fileName=$(basename -- "$fullPath")
			fileName=${fileName%.*}
			extension=${fullPath##*.}
			fileNamExt=$fileName.$extension
			newFileName=$(echo $fileName | tr -s '[:blank:]' '_')
			newFileName=$(echo $newFileName | tr '[:punct:]' '_')
			newFileName=$newFileName
			newFiNamExt=$newFileName.$extension
			newFullPath=$pathOnly/$newFiNamExt
			
			for ext in ${extensions[@]}
			do
                if [[ "$(toLowerCase "$ext")" == "$(toLowerCase "$extension")" ]]
				then
					
					fileOutput=$(basename -- "$pathOnly")
					fileOutput="$pathOnly/$fileOutput" #.txt file?
					#txtFileOut="$pathOnly/$newFileName.txt" #Text file for the user to add data    
					
					if [[ "$(toLowerCase "$fullPath")" != "$(toLowerCase "$newFullPath")" ]]
					then
						mv "$fullPath" "$newFullPath"
					fi					
					echo "$newFullPath ==> $fileOutput"
					echo $newFullPath >> $fileOutput 
					#>>$txtFileOut #if exists, check name to same name
					break
                fi
			done
			
		fi
	done
}

########### check for files renaming #### START
git config core.ignorecase false              #
hasChanged="$(git status --porcelain)"        #
git config core.ignorecase true               #
########### check for files renaming ###### END


date="`date '+%b %d, %Y; %H:%M:%S; %Z'`"

if [[ -n "$hasChanged" ]]
then
	echo "There are changes!";
	read -p "Enter a commit message: " userInput
	
	for dir in ${imagesDirectories[@]} #*/ #array=(*/)
	do
		processMediaFiles $(checkRootPathName $dir) ${imageExtensions[@]}
	done 
	### TEST
	########### git ls-files to array ####### START
	gitFilesTracked=$(git ls-files)               #
	git config core.ignorecase false              #
	gitFilesUnTracked=$(git ls-files -o)          #
	git config core.ignorecase true               #
	SAVEIFS=$IFS                                  # Save current IFS
	IFS=$'\n'                                     # Change IFS to new line
	gitFilesTracked=($gitFilesTracked)            # split to array $names
	gitFilesUnTracked=($gitFilesUnTracked)        # split to array $names
	IFS=$SAVEIFS                                  # Restore IFS
	########### git ls-files to array ######### END
	
	read -p "${#gitFilesTracked[@]} ========== ${#gitFilesUnTracked[@]}" #####-----------
	for fileTracked in "${gitFilesTracked[@]}"
	do
		echo "$fileTracked" ###
		for fileUnTracked in "${gitFilesUnTracked[@]}"
		do
			if [[ "$(toLowerCase "$fileTracked")" == "$(toLowerCase "$fileUnTracked")" ]]
			then
				echo "$fileTracked ==[${#gitFilesTracked[@]}, ${#gitFilesUnTracked[@]}]== $fileUnTracked"
				gitFilesUnTracked=("${gitFilesUnTracked[@]/$fileUnTracked}") #---
				git rm --cached "$fileTracked"
				git add "$fileUnTracked"
				break
			fi
		done
	done
	
	###
	
	echo $date>"date"
	#git add .
	#git commit -m "`date '+%Y-%m-%d %H:%M:%S'` => $userInput"
	#git push
	
	echo ""
	echo "Changes Date: $date"
else
	echo "There are NO changes!";
fi

read -p "Press [Enter] to continue..."

