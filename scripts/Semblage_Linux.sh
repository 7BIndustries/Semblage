#!/bin/bash

HELP_STRING="-v - Run Semblage with the --verbose option."
verbose=""

while getopts hv flag
do
        case "${flag}" in
		h) help=
			echo $HELP_STRING
			exit
		;;
                v) verbose=--verbose;;
        esac
done

LD_LIBRARY_PATH="$PWD/lib/" ./Semblage.x86_64 $verbose
