#!/bin/bash
. ~kjyi/src/parse
PARSE $@ << eof
# expand concatenated character(e.g. ,  ;  : | )seperated rows
# print to standard output
# Usage: `basename $0` [-t <str>] [-c|--col <str>] <input_file>
<file>			file	""	input file(positional argument)
-t <str>		sep		,	seperator of concatenated fields
-c|--col <str>	col		""	comma-separated field info e.g. 1,2,3
eof
python2.7 ~/src/pyr/expand.py $file $sep $col
