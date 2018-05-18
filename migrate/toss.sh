#!/bin/bash
usage="Usage:
	toss here
	toss ln
	toss cp
	toss scp
	toss mv
	toss swap"

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
	echo "error: no destination"
	exit 1
fi



if [ $1 == scp ]; then
	dest=`ssh 143.248.231.149 -p 2030 cat ~/.toss`
	echo $dest @workstation
	scp -r -P 2030 ${@:2} 143.248.231.149:$dest 
else
	dest=`cat ~/.toss`
	case $1 in

fi










if [ -d `cat ~/.toss` ]; then
	if [ "x$1" == "xmv" ]; then
		echo mv ${@:2} `cat ~/.toss`
		mv "${@:2}"	`cat ~/.toss`
	elif [ "x$1" == "xln" ]; then
		echo make soft links of ${@:2} to `cat ~/.toss`
		for i in ${@:2}; do
			ln -s `readlink -f $i` `cat ~/.toss`
		done
	elif [ "x$1" == "xcp" ]; then
		echo cp
		cp -a "${@:2}" `cat ~/.toss`
	else
		echo "no command $1; do one of mv/cp/ln"
	fi
else
	echo "not existing: `cat ~/.toss`"
fi

