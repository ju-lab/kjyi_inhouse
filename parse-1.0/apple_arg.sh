#!/bin/bash
. ~/src/parse
PARSE $@ << EOF 
#asdfasdf
#asdfs

# somthing else
#asdf

<faq>		p1			positional			Description of positional value1
<dir>		p2			ipositional arg2
-a|-A <txt>	apple		1  7					Description of the apple 
# C			O			M					MENT
#	 	asdf
#			 			 					Description
#			 			"default value"
-b <txt>	banana		"banana value"		Description of the banana
-c <txt>	canana		'cavana value'		Description of the banana
-V			bool1		false
-v			bool2		false
EOF
echo --------------RESULT----------------
cat <<eof
p1========$p1
p2========$p2
apple=====$apple
banana====$banana
canana====$canana
arguments=$arguments
bool1=====$bool1
bool2=====$bool2
========usag--------------
USAGE1 ----
$USAGE1
USGAE2 ---
$USAGE2
MATRIX ---
$MATRIX
FLAGS ---
${FLAGS[@]}
${VARS[@]}
Pos ----
${POS[@]}
REMAIN --
${REMAIN[@]}
eof
