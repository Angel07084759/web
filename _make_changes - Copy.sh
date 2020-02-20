#!/bin/bash

imageExtensions=(png jpg gif)				#tif Notsupported
videoExtensions=(mp4 webm ogg)				#
imagesDirectories=(images)                  #directoris and names should not contain spaces
videosDirectories=(videos)                  #

#if [[ "$(git config core.ignorecase)" == "false" ]]
git config core.ignorecase false
hasChanged="$(git status --porcelain)"
git config core.ignorecase true



function processMediaFiles() #params: 1>rootDirectory[@] 2>fileExtensions[@]
{
    echo "#################################" ################
    echo $1
    
    if [[ -d $1 ]]
	then
		file="$1/$(basename -- "$1")"
		>$file
		git add $file
		git mv $file tempLinksFile
		git mv tempLinksFile $file
    fi
    
    currentDir=$1
    shift
    extensions=($@)
    
	for file in "$currentDir"/* #Iterates current directory
	do
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
        
        if [[ -d $file ]]
		then
            processMediaFiles $file ${extensions[@]}
            #processMediaFiles $(checkDirName $file) ${extensions[@]}
        elif [[ -f $file ]]
		then
			
            for ext in ${extensions[@]}
			do
                if [[ "$ext" == "$(echo "$extension" | tr '[:upper:]' '[:lower:]')" ]]
				then
					
					fileOutput=$(basename -- "$pathOnly")
					fileOutput="$pathOnly/$fileOutput" #.txt file?
					#txtFileOut="$pathOnly/$newFileName.txt" #Text file for the user to add data
						
					git add "$fullPath"
					
					if [[ $fullPath != $newFullPath ]]
					then
						git mv "$fullPath" "$newFullPath"
						echo "$fileNamExt =>RENAMED=> $newFiNamExt"
					else
						tempPWD="$PWD"
						cd "$pathOnly"
						#git ls-files --error-unmatch "$newFiNamExt"
						
						for f in $(git ls-files)
						do
							if [[ "$(echo "$f" | tr '[:upper:]' '[:lower:]')" == "$(echo "$newFiNamExt" | tr '[:upper:]' '[:lower:]')" ]]
							then
								echo "$f <=?=> $newFiNamExt" ####
								if [[ "$f" != "$newFiNamExt" ]]
								then
									echo "$f => $newFiNamExt" ###
									git rm --cached "$f"
									git add "$newFiNamExt"
								fi
								break
							fi
						done						
						cd "$tempPWD"
					fi                
					echo "$newFullPath >> $fileOutput"
					echo $newFullPath >> $fileOutput 
					
					#>>$txtFileOut
					
					break
                fi
			done
        fi
    done
}

function checkDirName()
{
	temp=$1
	for file in *
	do
		if [[ "$(echo "$file" | tr '[:upper:]' '[:lower:]')"  == "$(echo "$temp" | tr '[:upper:]' '[:lower:]')" ]]
		then
			temp=$file
			break
		fi
	done
	echo $temp
}

date="`date '+%b %d, %Y; %H:%M:%S; %Z'`"

if [[ -n "$hasChanged" ]]
then
	echo "There are changes!";
	read -p "Enter a commit message: " userInput
	
	for dir in ${imagesDirectories[@]} #*/ #array=(*/)
	do
		processMediaFiles $(checkDirName $dir) ${imageExtensions[@]}
	done
	
	echo $date>"date"
	git add .
	git commit -m "`date '+%Y-%m-%d %H:%M:%S'` => $userInput"
	git push
	
	echo ""
	echo "Changes Date: $date"
else
	echo "There are NO changes!";
fi

read -p "Press [Enter] to continue..."

