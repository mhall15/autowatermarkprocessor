#!/bin/bash

#	*********************************************************
#	*	Auto Watermark Processor							*
#	*********************************************************
#	*														*
#	*	Writen By:  Michael Hall							*
#	*	Phone:      (310) 362-6522							*
#	*	Email:		michael.hall.lax@gmail.com				*
#	*														*
#	*********************************************************

#	Set active directory to location of executed command file.
cd `dirname $0`
clear

#	Application Directory Path Settings
SOURCE="./Scripts"
OUTPUT="./Output"
DISTRO="./Watermarks"

#	Bootstrap application directories. Only create directories if they do not exist.
mkdir -p $SOURCE
mkdir -p $DISTRO
mkdir -p $OUTPUT

#	Function: Animated Progress Bar
function ProgressBar {
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done

    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")

	printf "\rProgress : [${_fill// /#}${_empty// /-}] ${_progress}%%"
}

#	Output Application Title Banner
echo "┌─┐┬ ┬┌┬┐┌─┐  ┬ ┬┌─┐┌┬┐┌─┐┬─┐┌┬┐┌─┐┬─┐┬┌─  ┌─┐┬─┐┌─┐┌─┐┌─┐┌─┐┌─┐┌─┐┬─┐";
echo "├─┤│ │ │ │ │  │││├─┤ │ ├┤ ├┬┘│││├─┤├┬┘├┴┐  ├─┘├┬┘│ ││  ├┤ └─┐└─┐│ │├┬┘";
echo "┴ ┴└─┘ ┴ └─┘  └┴┘┴ ┴ ┴ └─┘┴└─┴ ┴┴ ┴┴└─┴ ┴  ┴  ┴└─└─┘└─┘└─┘└─┘└─┘└─┘┴└─";

#	Error Checking: Detect if SOURCE directory contains files for processing. If not, exit application.
if [ `ls -1 $SOURCE | wc -l` -eq 0 ]; then
		printf '\n'
		echo "${SOURCE/.\/} directory must contain a PDF file for processing."
		echo "Application terminated prematurely."
		printf '\n\n'
		exit 10
fi

#	Error Checking: Detect if DISTRO directory contains files for processing. If not, exit application.
if [ `ls -1 $DISTRO | wc -l` -eq 0 ]; then
		printf '\n'
		echo "${DISTRO/.\/} directory must contain at least 1 watermark PDF for processing."
		echo "Application terminated prematurely."
		printf '\n\n'
		exit 11
fi

#	Normalize all files in SOURCE directory from spaces to underscores.
cd $SOURCE
for f in *; do
	mv "$f" `echo $f | tr ' ' '_'`
done
cd ..

#	Output total workload expected from the application for user spotchecking.
printf '\n'
echo "Total Scripts Detected for Watermarking:    `ls -1 $SOURCE | wc -l`"
echo "Total Watermarks Detected for Distribution: `ls -1 $DISTRO | wc -l`"
printf '\n\n'

#	Present user with options if OUTPUT directory is not empty.
if [ `ls -1 $OUTPUT | wc -l` -gt 0 ]; then
		echo "The ${OUTPUT/.\/} directory is not empty. Please select an action below:"
		printf '\n'

		OPTIONS=("Delete Files" "Overwrite Files" "Abort and Quit")
		select opt in "${OPTIONS[@]}"; do
			case $opt in
				"Delete Files")
					rm -f $OUTPUT/*
					break
					;;
				"Overwrite Files")
					break
					;;
				"Abort and Quit")
					printf '\n\n'
					echo "Script processing aborted. Application terminated."
					exit
					;;
				*)
					echo "Invalid option selected. Please select from the available options."
					;;
			esac
		done
		printf '\n'
fi 



#	Loop through each file in the SOURCE directory.
for sourcePDF in `ls -1 $SOURCE`; do
	echo "Processing: $sourcePDF"
	i=1

#	Loop through each file in the DISTRO directory and apply the watermark to the current loop SOURCE file.
	for watermark in `ls -1 $DISTRO`; do

#	Display progress bar to indicate to user that application is still actively processing documents.
		ProgressBar $i `ls -1 $DISTRO | wc -l`
		pdftk $SOURCE/$sourcePDF stamp $DISTRO/$watermark output "$OUTPUT/${sourcePDF/.pdf} $watermark"
		i=$((i+1))
	done
	printf '\n\n'
done


#	Output information to advise user of completion status.
echo "All scripts have been watermarked successfully."
echo "Processed scripts are in the ${OUTPUT/.\/} directory."
printf '\n\n'
echo "    \|/ ____ \|/"
echo "     @~/ ,. \~@              HAPPY"
echo "    /_( \__/ )_\\               DISTRO-ING!"
echo "       \__U_/"
printf '\n'

#	Terminate Application Normally
exit 0