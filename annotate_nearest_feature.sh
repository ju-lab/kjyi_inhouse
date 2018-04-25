#!/bin/bash
#~/src/annotate_nearest_genes.sh
. ~kjyi/src/parse
PARSE $@ << EOF
# Annotate nearest N featuers in given reference bed, to given bed format file.
# WARNING: The output will be lexicographically sorted.
#          ANY INPUT will be transformed to enembl style chromosome name (1, 2, 3 MT) not (chr1 chrM)
-t	target	""				target file to be annotated
-f	feature	""				reference feature such as gencode, ensembl feature coordinate
-o	output	"annotate.tmp"	output file path/name
-n	number	"1"				number of annotated genes (first upstream, second upstream ...)
-N	Nearest	false			if yes, only the closest(any direction) will be annotated. Ties take left one.
EOF

cf=~kjyi/tools/bedops-2.4.30/closest-features
sb=~kjyi/tools/bedops-2.4.30/sort-bed
td=tmp.annotation
mkdir -p $td
rm -f $td/*

sed 's/^chrM/chrMT/;s/^chr//' $target > $td/tmp
$sb $td/tmp > $td/1.up
cp $td/1.up $td/1.down
#rm $td/tmp
sed 's/^chrM/chrMT/;s/^chr//' $feature > $td/tmp2

cut -f1 $td/1.up | uniq | awk '{print $1"\t0\t1\tfake\n"$1"\t999999998\t999999999\tfake"}' >> $td/tmp2

$sb $td/tmp2 > $td/f
#rm $td/tmp2

NCOL=`head -n1 $td/tmp2 | wc -w`
NA=$((for i in $(seq $NCOL);do echo -en 'NA\t';done;echo)|sed 's/\t$//' )
if $Nearest ; then 
	cl="--closest"
	number=1
else
	cl=""
fi

for i in `seq $number`; do
	echo i---------$i
#	$cf $cl $td/$i.down $td/f | awk -F '|' '{print $2}' - | sed 's/^NA$/0\t0\t0/' > $td/$((i+1)).down
#	sed 's/^0\t0\t0$/'"$NA"'/' $td/$((i+1)).down > $td/$((i+1)).down.na	
	$cf $cl $td/$i.down $td/f | awk -F '|' '{print $2}' - > $td/$((i+1)).down && echo aa
	if ! $Nearest ; then 
#		$cf $cl $td/$i.up $td/f | awk -F '|' '{print $3}' - | sed 's/^NA$/Z\t0\t0/' > $td/$((i+1)).up
#		sed 's/^Z\t0\t0$/'"$NA"'/' $td/$((i+1)).up > $td/$((i+1)).up.na
		$cf $cl $td/$i.up $td/f | awk -F '|' '{print $3}' - > $td/$((i+1)).up && echo aaaa
	fi
done
mv $td/1.down  $td/original
rm -f $td/1.up
if  $Nearest ; then 
	paste -d'\t' $td/original $td/*.down > $td/final.tmp && echo bb
else
	paste -d'\t' $td/original $td/*.up $td/*.down > $td/final.tmp && echo BB
fi
echo $NCOL
head $td/f
sed "s/[^\t]*\t0\t1\tfake/$NA/g;s/[^\t]*\t999999998\t999999999\tfake/$NA/g" $td/final.tmp > $output
#rm -rf $td
