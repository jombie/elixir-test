#!/usr/bin/env bash
#/**
#*    Copyright 2015
#*/

#Change to the directory where this script is present does not work if run using sh minions
bin=`which $0`
bin=`dirname ${bin}`
bin=`cd "$bin"; pwd`

#Below are used for coloring output, Other Colors are Brown/Orange=0;33, Yellow=1;33, Purple=0;35, Cyan=0;36
R='\033[0;31m'
G='\033[0;32m'
N='\033[0m' # No Color

#Default values
DEFAULT_INSTALLATION_DIR="/mnt/install"
DEFAULT_INSTALL_COMMAND="all"
DEFAULT_TAR_EXTENSION="tar.gz"

#Software package download urls
DOWNLOAD_JAVA_URL="http://download.oracle.com/otn-pub/java/jdk/8u51-b16/jdk-8u51-linux-x64.tar.gz"
DOWNLOAD_ERLANG_URL="http://www.erlang.org/download/otp_src_18.0.tar.gz"
DOWNLOAD_ELIXIR_URL="https://github.com/elixir-lang/elixir/archive/v1.0.5.tar.gz"
DOWNLOAD_PHOENIX_URL="http://download.oracle.com/otn-pub/java/jdk/8u51-b16/jdk-8u51-linux-x64.tar.gz"

#Sofwares download folder names, version is appended based on above urls
JAVA_NAME="java_1.8.0_51"
ERLANG_NAME="erlang_otp_18.0"
ELIXIR_NAME="elixir_1.0.5"

function main() {
	#If no argument provided exit showing help
	if [ $# = 0 ]; then
	  print_usage
	  exit
	fi

	#Parse Commands and perform actions
	COMMAND=$1
	case $COMMAND in
	  # usage flags
	    install)

		if which wget >/dev/null; then
			echo "wget is installed will use this to download packages"
		else
			echo "wget must be installed to download files."
			exit
		fi

		if [ -z "$2" ]; then export SUBCOMMAND=$DEFAULT_INSTALL_COMMAND; else export SUBCOMMAND=$2; fi
		if [ -z "$3" ]; then export installDir=$DEFAULT_INSTALLATION_DIR; else export installDir=$3; fi
		printf "\n${G}Base installation directory : $installDir${N}\n"
		case $SUBCOMMAND in
			all)
				printf "\n${G}Installing Java-1.8u51, Erlang/OTP-18.0, Elixir-1.0.5, PhoenixFramework-0.14.0${N}\n"
				printf "\n${G}Successfully installed packages${N}\n"
				exit
			;;
			java)
				printf "\n${G}Installing Java-1.8u51 ${N}\n"
				install_java	
				printf "\n${G}Successfully installed Java-1.8u51${N}\n"
				exit
			;;

			erlang)
				printf "\n${G}Installing Erlang/OTP-18.0 ${N}\n"
				install_erlang
				printf "\n${G}Successfully installed Erlang/OTP-18.0${N}\n"
				exit
			;;

			elixir)
				printf "\n${G}Installing Elixir-1.0.5 ${N}\n"
				install_elixir
				printf "\n${G}Successfully installed Elixir-1.0.5${N}\n"
				exit
			;;
		
		esac
		;;
		
	     *)
		echo "ERROR : Command \"$COMMAND\" is not available. Please use a valid command."
		exit
		;;	  
	esac
}

#Print usage for this script
function print_usage() {
  printf "\nUsage: minions COMMAND where COMMAND is one of:\n"
  echo "install all    [installation directory]"
  echo "install java   [installation directory]"
  echo "install erlang [installation directory]"
  echo "install elixir [installation directory]"
  echo ""
}

#Downloads and install java
function install_java() {
	ExtractFolderName=$installDir/$JAVA_NAME
	ExtractFileName=$ExtractFolderName"."$DEFAULT_TAR_EXTENSION
	mkdir -p $ExtractFolderName
	(set -x; wget -O $ExtractFileName --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" $DOWNLOAD_JAVA_URL)
	(set -x; tar -xvf $ExtractFileName -C $ExtractFolderName --strip-components 1) || return
	(set -x; rm -f $ExtractFileName)
	(set -x; echo "export JAVA_HOME=$ExtractFolderName" >> ~/.bashrc)
	(set -x; echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> ~/.bashrc)
	(set -x; ln -s $ExtractFolderName/bin/java /usr/local/bin/java > /dev/null 2>&1 || true) 
	(set -x; ln -s $ExtractFolderName/bin/javac /usr/local/bin/javac > /dev/null 2>&1 || true)
	(set -x; ln -s $ExtractFolderName/bin/jps /usr/local/bin/jps > /dev/null 2>&1 || true)
	(set -x; $ExtractFolderName/bin/java -version)
}

#Downloads and install erlang
function install_erlang() {
	if which java > /dev/null 2>&1; then 
		echo "Using pre installed java"
	else 
		printf "${R}Java not found. Erlang requires java to compile some java dependent modules.\nIf not installed those modules will be skipped.${N}\n"
		read -t 10 -p "Do you want to install java? [Y/N] (Default Y after 10 sec) " choice
		if [ -z "$choice" ]; then choice="Y"; fi
		if [ "$choice" == "y" -o "$choice" == "Y" ]; then
			install_java
		fi	
	fi

	ExtractFolderName=$installDir/$ERLANG_NAME
	ExtractFileName=$ExtractFolderName"."$DEFAULT_TAR_EXTENSION
	mkdir -p $ExtractFolderName
	(set -x; wget -O $ExtractFileName $DOWNLOAD_ERLANG_URL)
	(set -x; tar -xvf $ExtractFileName -C $ExtractFolderName --strip-components 1) || return
	(set -x; rm -f $ExtractFileName)
	(set -x; yum install -y gcc gcc-c++ glibc-devel make ncurses-devel openssl-devel autoconf) || return
        CFLAGS="-DOPENSSL_NO_EC=1"
        (set x; cd $ExtractFolderName && ./configure) || return
        (set x; cd $ExtractFolderName && make) || return
        (set x; cd $ExtractFolderName && sudo make install) || return
        (set -x; erl -version)
}

#Downloads and install elixir
function install_elixir() {
	if which erl > /dev/null 2>&1; then 
		echo "Using pre installed erlang"
	else 
		printf "${R}Erlang not found. Elixir requires erlang, installing erlang...${N}\n"
		install_erlang
	fi

	ExtractFolderName=$installDir/$ELIXIR_NAME
	ExtractFileName=$ExtractFolderName"."$DEFAULT_TAR_EXTENSION
	mkdir -p $ExtractFolderName
	(set -x; wget -O $ExtractFileName $DOWNLOAD_ELIXIR_URL)
	(set -x; tar -xvf $ExtractFileName -C $ExtractFolderName --strip-components 1) || return
	(set -x; rm -f $ExtractFileName)
	(set x; cd $ExtractFolderName && make) || return
	(set -x; echo "export ELIXIR_HOME=$ExtractFolderName" >> ~/.bashrc)
	(set -x; echo "export PATH=\$ELIXIR_HOME/bin:\$PATH" >> ~/.bashrc)
	(set -x; ln -s $ExtractFolderName/bin/elixir /usr/local/bin/elixir > /dev/null 2>&1 || true) 
	(set -x; ln -s $ExtractFolderName/bin/elixirc /usr/local/bin/elixirc > /dev/null 2>&1 || true) 
	(set -x; ln -s $ExtractFolderName/bin/iex /usr/local/bin/iex > /dev/null 2>&1 || true)
	(set -x; ln -s $ExtractFolderName/bin/mix /usr/local/bin/mix > /dev/null 2>&1 || true)
	(set -x; $ExtractFolderName/bin/elixir -v)
}

#main "$@"
main install all < /dev/tty
