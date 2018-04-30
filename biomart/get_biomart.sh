#!/bin/bash
. ~kjyi/src/parse
PARSE $@ << EOF
# Simple biomart table downloader
# Browse biomart, select desired entries, and then save (or copy to clipboard) accession xml file
# if you saved file, give it as input
# Arguments:
-i	input		""				Input XML format file
-o 	output		interactive		output
-v	vim_mode	false			enter vim mode
EOF
if [[ "x$input" == "x" ]];then
	input=.tmp_biomart_xml
	echo -en "# Paste content of xml file\n\n" > $input
	vi $input
fi
query_t=`cat $input|sed '/^#/d;/^\s*$/d'`
if [ "x$query_t" == "x" ]; then echo "Empty query"; exit 1; fi
query=`echo "$query_t" | tr -d '\n'| tr -d '\t'`
if [ "x$output" == "xinteractive" ]; then
		read -p "Save to: " output
		if [ "x$output" == "x" ]; then echo "Please enter output file name (exit)" ;exit 1; fi
fi
wget -O $output "http://www.ensembl.org/biomart/martservice?query=$query"

