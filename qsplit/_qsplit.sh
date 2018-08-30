#!/bin/bash
. ~kjyi/src/parse
PARSE $@ << eof
#QSUB
-bi	batch_interval	1		batch interval (number of &+1)
-lp	log_prefix		log/cmd	log prefix
eof

mkdir -p $(dirname $log_prefix)


cat ${REMAIN[@]} |\
	sed '/^$/d;' |
	sed '=' |
	sed '{N; s/\n/ /};' |
	sed 's!\([0-9]*\) \(.*\)!(\2)\&>'$log_prefix'.\1.log \&\& mv '$log_prefix'.\1.log '$log_prefix'.\1.done;if [ -f '$log_prefix'.\1.log ]; then mv '$log_prefix'.\1.log '$log_prefix'.\1.fail \&!'|
	sed '1~'$batch_interval' i wait' | sed '1d'
echo wait
