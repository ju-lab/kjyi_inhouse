#!/bin/bash
less -f "$1" |
sed -nr '
/^##/ { /INFO=<ID=CSQ/! p }
/INFO=<ID=CSQ/ {
	s/.*Format: /##INFO<ID=VEP_/
	s/\|/,Number=.,Type=Character,Description="annotated by vep">\n##INFO<ID=VEP_/g
	s/">$//
	s/$/,Number=.,Type=Character,Description="annotated by vep">/
	p
}
/^#CHR/ p
/^#/! p
'| R --slave << EOF
library(stringr)
f <- file("stdin")
while(length(line <- readLines(f, n=1)) > 0) {

	write(line, stdout())
}
EOF
