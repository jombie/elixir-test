#!/bin/bash 
URL=https://github.com/jombie/elixir-test/blob/master/scripts/minions_install.bash
function download { 
	scratch=$(mktemp -d -t tmp.XXXXXXXXXX) || exit 
	script_file=$scratch/minions_install.bash 
	echo "Downloading minions install script: $URL" 
	curl -# $URL > $script_file || exit 
	chmod 755 $script_file 
	echo "Running install script from: $script_file" 
	$script_file 
} 
download < /dev/tty
