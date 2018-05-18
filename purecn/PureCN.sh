#!/bin/bash
if [ "$#" == "0" ]; then
	cat <<EOF 1>&2
# $0 <task> [arguments]
# task:
#	PureCN
#	Coverage
#	downloadCentromeres
#	Dx
#	FilterCallableLoci
#	IntervalFile
#	NormalDB
EOF
exit 1
fi

#extdir=/home/users/kjyi/tools/R/R-3.4.0/lib64/R/library/PureCN/extdata
extdir=/home/users/kjyi/anaconda3/lib/R/library/PureCN/extdata
/home/users/kjyi/anaconda3/bin/Rscript $extdir/${1/%.R/}.R ${@:2}

