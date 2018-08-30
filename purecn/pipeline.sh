#!/bin/bash
. ~kjyi/src/parse
PARSE $@ << __PARSE__
#Run MT2 call, filter, gatkCNVtool, purecn
#Standard input as tabular structure of
#TUMOR_BAM	NORMAL_BAM
#TUMOR_BAM	NORMAL_BAM
#TUMOR_BAM	NORMAL_BAM
-i	interval	''	interval_file_as...
-T	thread		24	total_thread
__PARSE__

cat /dev/stdin |
while read tb nb; do
	mutect2.sh $tb $nb; 
done

