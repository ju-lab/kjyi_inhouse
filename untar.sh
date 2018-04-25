#!/bin/bash
# unzip all input files

for i in $*; do
if [[ $i == *.tar.bz2 ]]; then
		tar -xjvf $1
	elif [[ $i == *.tar.gz ]]; then
		tar -xzvf $1
	elif [[ $i == *.tgz ]]; then
		tar -xzvf $1
	elif [[ $i == *.zip ]]; then
		/usr/bin/unzip $i
	elif [[ $i == *.gz ]]; then
		gzip -d $i
	else
		echo "I don't understand the file type"
fi
done
