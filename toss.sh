#!/bin/bash
usage=" ~/src/toss.sh
toss here
toss ln *.gz  # softlink to absolute path
toss cp *.gz  # copy with -a
toss mv *.gz"

if [ "x$1" == "xhere" ]; then
	pwd > ~/.toss
	cat ~/.toss
	exit 0
fi

if [ "x$1" == "x" ]; then
	if [ -f ~/.toss ]; then
		cat ~/.toss
	fi
	echo "$usage"
	exit 0
fi


if [ ! -f ~/.toss ]; then
	echo $HOME > ~/.toss
fi

if [ -d `cat ~/.toss` ]; then
	cat ~/.toss
	if [ "x$1" == "xmv" ]; then
		echo mv
		mv "${@:2}"	`cat ~/.toss`
	elif [ "x$1" == "xln" ]; then
		echo ln
		for i in ${@:2}; do
			ln -s `readlink -f $i` `cat ~/.toss`
		done
	elif [ "x$1" == "xcp" ]; then
		echo cp
		cp -a "${@:2}" `cat ~/.toss`
	elif [ "x$1" == "xswap" ]; then
		echo mv and make symbolic link
		echo "${@:2} <--> `cat ~/.toss`"
		mv "${@:2}" `cat ~/.toss`
		for i in ${@:2};do
			ln -s `cat ~/.toss`/`basename $i` $(dirname $i)
		done

	else
		echo "no command $1; do one of mv/cp/ln"
	fi
else
	echo "not existing: `cat ~/.toss`"
fi

