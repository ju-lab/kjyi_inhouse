#!/bin/bash
#' easy way to delete PBS jobs
#' qqdel jobname_bwa*.sh
#' qqdel 1..10     (job id), kill only mine

USAGE="""Delete multipe jobs in one command
usage: qqdel 1..10 (job id)
       qqdel jobname* (using grep)
       qqdel -all
       qqdel 1..10 15..20 jobname_grep_text"""

for var in "$@"; do
	if [ "$var" = "-h" ] || [ "$var" = "--help" ]; then
		echo "$USAGE"
		exit 1
	fi
done
if [ $# -eq 0  ]; then
	echo "$USAGE"
	exit 1
fi

for var in "$@"; do
	if [ "$var" = "-all" ]; then
	 	qstat | grep -v ' C ' | grep $USER | cut -d . -f1 | xargs qdel
	elif [[ $var == *".."* ]]; then
		qdel $(eval echo "{$var}")
	else
	 	qstat -u $USER | grep "$var" | grep -v ' C ' | cut -d . -f1 | xargs qdel
	fi
done


