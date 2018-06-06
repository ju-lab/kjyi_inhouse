#!/bin/bash
yes='[^|\t;,]*\|[^|\t;,]*\|[^|\t;,]*\|[^|\t;,]*\|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|[^|\t;,]*|YES'
less -f "${1:-/dev/stdin}"|
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
/^#/! {
	/[,=]'$yes'/{

	s/CSQ=.*('$yes')[^\t]*/aaaa\1bbbb/
	p
	}
}

'
