#!/bin/bash

#git config core.ignorecase false
#	git ls-files
#git config core.ignorecase true
#	echo "================"
#	git ls-files #---
#gitFiles=($(git ls-files))
#echo ${#gitFiles[@]}
#read -p "PRESS ENTER" #---
#arg="${arg/ /\ }"
#$(echo $arg | tr -s '[:blank:]' '_')

function checkCaseSensitiveA() #"$1" == "" ? "*" : "$1"
{
	arg="$1"/*
	if [[ "$1" == "" ]]; then arg="*"; fi
	echo "$arg"
	for myFile in "$arg"
	do
		if [[ -d "$myFile" ]]
		then
			#echo "==>$myFile"
			checkCaseSensitive "$myFile"
			#echo "<==$myFile"
		else
			echo "${#gitFiles[@]} $myFile" #####-----------
			for f in $gitFiles
			do
				
				if [[ "$(echo "$f" | tr '[:upper:]' '[:lower:]')" == "$(echo "$myFile" | tr '[:upper:]' '[:lower:]')" ]]
				then
					gitFiles=("${gitFiles[@]/$f}") #---
					echo "$f <=?=> $myFile" ####
					if [[ "$f" != "$myFile" ]]
					then
						echo "$f => $myFile" ###
						#git rm --cached "$f"
						#git add "$myFile"
					fi
				break
				fi
			done	
		fi
	done
}

function checkCaseSensitiveB() #"$1" == "" ? "*" : "$1"
{
	#arg="${1/ /\ }"/*
	arg="$1/*"
	if [[ -z "$1" ]]; then arg="*"; fi
	#if [[ "$arg" =~ \ |\' ]]; then arg="$1"/* ; fi
	echo "[$arg]" && [[ "$arg" =~ \ |\' ]] && echo ">>>>>   $arg HAS SPACES" #####
	
	if [[ "$arg" =~ \ |\' ]]
	then 
	
		for myFile in "$1"/*
		do
			if [[ -d "$myFile" ]]
			then		
				echo "**** A[$myFile] ****"
				#if [[ "$myFile" =~ \ |\' ]]; then myFile=${myFile/ /\ }; fi
				checkCaseSensitiveB "$myFile"
			else
				echo "=>$myFile"
			fi
		done
	else
		for myFile in $arg
		do
			#echo ">> $myFile" #############
			if [[ -d "$myFile" ]]
			then		
				echo "**** B[$myFile] ****"
				#if [[ "$myFile" =~ \ |\' ]]; then myFile=${myFile/ /\ }; fi
				checkCaseSensitiveB "$myFile"
			else
				echo "=>$myFile"
			fi
		done
	fi
}

function checkCaseSensitive() #"$1" == "" ? "*" : "$1"
{
	arg="$1/*"
	if [[ -z "$1" ]]; then arg="*"; fi
	[[ "$arg" =~ \ |\' ]] && echo ">>>>>   $arg HAS SPACES" #####
	if [[ "$arg" =~ \ |\' ]]; then arg="$1"/* ; fi
	
	
 	
	for myFile in $arg
	do
		if [[ -d "$myFile" ]]
		then		
			echo "**** [$myFile] ****"
			#if [[ "$myFile" =~ \ |\' ]]; then myFile=${myFile/ /\ }; fi
			checkCaseSensitive "$myFile"
		else
			echo "=>$myFile"
		fi
	done
}



checkCaseSensitive

#for f in "dir test"/* ; do	echo $f; done
read -p "PRESS ENTER"


