#!/bin/bash
#~/src/atac/runpool.sh
. ~/src/parse.sh
PARSE $@ <<EOF
# Generate pooled dataset and pooled-pseudoreplicates
# Usage: `basename $0` <dir to tagAlign,pseudoreplicated tagAlign1, and 2>
# Arguments:
<input_dir>				input_dir	'./atac'					
--sample_name_pattern	pattern		'\([^\]*\).tr5.tagAlign.gz'
--sample_ext			sample_ext	'tn5.tagAlign.gz'
--pr1_ext				pr1_ext		'pr1.tagAlign.gz'
--pr2_ext				pr2_ext		'pr2.tagAlign.gz'
--log <path>			log			./log/atac
--memory <nnGB>			memory		30GB
--thread <4-24>			thread		6
--dry					dry			no
EOF

LOG=$log/pool.`date +'%Y%m%d%H%M'`.log
touch $LOG
LOG=`readlink -f $LOG`
matrix=./pool_matrix_`date +'%Y%m%d.tsv'`
pushd $input_dir > /dev/null
sample_list=`find -L * | grep -v 'ppr1.tagAlign' | grep -v "ppr2.tagAlign" | \
		grep -v "pooled.tagAlign" | grep -E $sample_ext'|'$pr1_ext'|'$pr2_ext | sort`

if [ ! -f $matrix ]; then
cat <<EOF > $matrix
# group replicates
rep_group	sample_name	sample_tn5	pseudorep1	pseudorep2
`echo "$sample_list" | sed 'N;N;s/\n/\t/g' | sed 's/\([^/\t]*\).pr1.tagAlign.*/\1\t\1\t&/'`
EOF
vi $matrix
fi

groups=`cat $matrix | grep -v "^#" |tail -n+2| cut -f1 |uniq|sort`
cat $matrix
echo groups $groups
for i in $groups; do
	echo repgroup $i
	tag=`grep $i $matrix | cut -f5`
	echo tag $tag
	if [ ! `echo $tag | wc -w` == 1 ]; then
		pr1=`grep $i $matrix | cut -f3`
		echo pr1 $pr1
		pr2=`grep $i $matrix | cut -f4`
		echo pr2 $pr2
		output1=$i.pooled.tagAlign.gz
		output2=$i.ppr1.tagAlign.gz
		output3=$i.ppr2.tagAlign.gz
		zcat $tag | gzip -nc > $output1 &
		zcat $pr1 | gzip -nc > $output2 &
		zcat $pr2 | gzip -nc > $output3 &
	fi
done
popd > /dev/null
wait
echo done
