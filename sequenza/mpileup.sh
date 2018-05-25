#!/bin/bash
. ~kjyi/src/parse
PARSE $@ << EOF
# $0 [options] <input.bam> [input2.bam]...
#
# output will be follow intput file name
-t <int>	thread		10	 	
-r <path>	reference	hg19	hg19|hg38|other_fastq_file
-c			stdout		false	print to standard output (ommit -o)
-o			outdir		.		output directory
-z			compress	false	compress the output
-e			stderr		/dev/stderr
EOF
set -e
case $reference in
	hg19) reference=/home/users/kjyi/ref/hg19.fa ;;
	hg38) reference=/home/users/kjyi/ref/hg38.fa ;;
esac

bcftools=/home/users/kjyi/tools/bcftools-1.5/bcftools
samtools=/home/users/kjyi/tools/samtools/samtools-1.6/bin/samtools

if [ ! "x$PBS_O_WORKDIR" == "x" ]; then cd $PBS_O_WORKDIR; fi

cat << EOF > $stderr
# -------------------
# mpileup in parallel
# -------------------
# thread:$thread
# reference:$reference
# 
EOF
for i in ${REMAIN[@]}; do 
	date_seed=`date +%Y%m%d%H%m%S`
	random_seed=`shuf -i 10-99 -n1`
	prefix=$date_seed-$random_seed
	if $stdout; then
		output=/dev/stdout
	else
		mkdir -p $outdir
		output=$outdir/`basename ${i/%.bam/.mpileup.vcf}`
	fi
	echo "# $i" > $stderr
	$samtools view -H $i | \
		grep "\@SQ" | \
		sed 's/^.*SN://g' | \
		cut -f 1 | \
		xargs -I {} -n 1 -P $thread sh \
		-c "$samtools mpileup -BQ20 -q 20 -d 100000 -f $reference -r {} $i 1> $outdir/tmp.$prefix.{}.vcf 2> $stderr"
	$samtools view -H $i | \
		grep "\@SQ" | \
		sed 's/^.*SN://g' | \
		cut -f 1 | \
		perl -ane 'system("cat '$outdir'/tmp.'$prefix'.$F[0].vcf >> '$output'");'
	rm $outdir/tmp.$prefix.*.vcf
	if $compress; then gzip $output ; fi
done
wait

